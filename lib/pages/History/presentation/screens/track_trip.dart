import 'dart:async';
import 'dart:convert';
import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/History/bloc/history_bloc.dart';
import 'package:truklynk/pages/History/bloc/history_event.dart';
import 'package:truklynk/pages/History/data/models/journey_details.dart';
import '../../../../utils/helper_functions.dart';
import '../../../../utils/helper_model.dart';
import '../../../Order/data/models/map.dart';
import '../../bloc/history_state.dart';
import '../../data/models/booking_model.dart';
import '../../data/repository/history_repo.dart';
import '../constants/history_theme.dart';
import 'package:http/http.dart' as http;

class TrackTrip extends StatefulWidget {
  final Booking booking;

  TrackTrip({Key? key, required this.booking}) : super(key: key);

  @override
  State<TrackTrip> createState() => _TrackTripState();
}

class _TrackTripState extends State<TrackTrip> {
  late HistoryBloc historyBloc;
  Future<InitMap>? _mapStyleFuture;
  final Completer<GoogleMapController> _controller = Completer();
  int activeIndex = 0;
  BitmapDescriptor? vehicleIcon;
  bool isInitialPositionSet = false;
  DateTime lastUpdated = DateTime.now();
  int? vehicleSno;
  late JourneyDetails journeyDetails;
  Timer? _locationUpdateTimer;
  final HistoryRepo historyRepo = HistoryRepo();

  bool isLoading = false;
  final ValueNotifier<int> activeIndexNotifier = ValueNotifier<int>(0);
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final String googleMapsApiKey = 'AIzaSyCq3n0PuZCtun6j0kiLnprf0mEqgQOvGls';

  @override
  void initState() {
    historyBloc = HistoryBloc()
      ..add(GetJourneyDetails(
          service_booking_sno: widget.booking.serviceBookingSno!));
    vehicleSno = widget.booking.vehicleSno;
    if (vehicleSno != null) {
      _startLocationTracking();
    }
    _loadVehicleMarker();
    _mapStyleFuture = _loadMapStyle();
    super.initState();
  }

  @override
  void dispose() {
    historyBloc.close();
    _locationUpdateTimer?.cancel(); // Cancel the timer
    _locationUpdateTimer = null;
    super.dispose();
  }

  Future<void> _loadVehicleMarker() async {
    try {
      debugPrint('Loading vehicle icon using alternative method');

      final ByteData data = await rootBundle.load('assets/images/car_icon.png');
      final Uint8List bytes = data.buffer.asUint8List();
      vehicleIcon = BitmapDescriptor.fromBytes(bytes);

      debugPrint('Vehicle icon loaded from bytes successfully');
    } catch (e) {
      debugPrint('Error loading vehicle icon: $e');
      // vehicleIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  void _startLocationTracking() {
    print('Starting location tracking for vehicleSno: $vehicleSno');
    _fetchVehicleLocation(
        isInitialLoad: true); // Initial load with loading indicator

    // Periodic updates without loading indicator
    _locationUpdateTimer?.cancel(); // Cancel any existing timer
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchVehicleLocation(
            isInitialLoad: false); // Periodic update without loading
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchVehicleLocation({bool isInitialLoad = false}) async {
    print('vehicleSno$vehicleSno');

    if (!mounted) return;

    // Only show loading indicator for the initial load
    if (isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final lastLocation =
          await historyRepo.getLastVehicleLocation(vehicleSno!);
      print('lastLocation$lastLocation');

      if (lastLocation != null) {
        final double lat =
            double.tryParse(lastLocation['lat'].toString()) ?? 0.0;
        final double lng =
            double.tryParse(lastLocation['lng'].toString()) ?? 0.0;
        final double heading =
            double.tryParse(lastLocation['heading']?.toString() ?? '0') ?? 0.0;

        // Update vehicle position without triggering full rebuild
        _updateVehiclePosition(lat, lng, heading);

        // Update lastUpdated timestamp (only trigger setState if necessary)
        lastUpdated = DateTime.now();

        // Move camera only for initial load or if explicitly desired
        if (isInitialLoad && mounted) {
          final GoogleMapController controller = await _controller.future;
          controller
              .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
        }
      }
    } catch (e) {
      print('Error fetching vehicle location: $e');
    } finally {
      if (isInitialLoad && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateVehiclePosition(double lat, double lng, double heading) {
    final LatLng position = LatLng(lat, lng);

    debugPrint(
        'Updating vehicle position: Lat: $lat, Lng: $lng, Heading: $heading');
    debugPrint(
        'Vehicle icon status: ${vehicleIcon != null ? "Loaded" : "Null"}');

    setState(() {
      markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('vehicle'));
      final marker = Marker(
        markerId: const MarkerId('vehicle'),
        position: position,
        icon: vehicleIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: heading,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 2,
        infoWindow: const InfoWindow(
          title: 'Vehicle Location',
          snippet: 'Current position of the vehicle',
        ),
      );
      markers.add(marker);
      debugPrint('Marker added to set with icon: ${marker.icon.toString()}');
    });

    if (!isInitialPositionSet) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
        isInitialPositionSet = true;
      });
    }
  }

  void _addMarkersAndPolyline() async {
    if (journeyDetails.pickupLocation?.latlng != null &&
        journeyDetails.dropLocation?.latlng != null) {
      final LatLng pickupLatLng = LatLng(
        journeyDetails.pickupLocation!.latlng!.latitude!,
        journeyDetails.pickupLocation!.latlng!.longitude!,
      );

      final LatLng dropLatLng = LatLng(
        journeyDetails.dropLocation!.latlng!.latitude!,
        journeyDetails.dropLocation!.latlng!.longitude!,
      );

      // Add markers
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng,
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: journeyDetails.pickupLocation!.address,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: dropLatLng,
          infoWindow: InfoWindow(
            title: 'Drop Location',
            snippet: journeyDetails.dropLocation!.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Fetch polyline points
      final polylinePoints =
          await fetchPolylinePoints(pickupLatLng, dropLatLng, googleMapsApiKey);

      // Add polyline
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );

      // Update camera position
      _updateCameraPosition(pickupLatLng, dropLatLng);
    }
  }

  Future<List<LatLng>> fetchPolylinePoints(
      LatLng origin, LatLng destination, String apiKey) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<LatLng> polylinePoints = [];

      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        polylinePoints.addAll(_decodePolyline(points));
      }

      return polylinePoints;
    } else {
      throw Exception('Failed to load polyline points');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Function to update the camera position
  Future<void> _updateCameraPosition(LatLng pickup, LatLng drop) async {
    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<Position?> checkPermission(LocationAccuracy accuracy) async {
    CustomePermission permission = await checkGpsPermission();
    if (permission.status) {
      try {
        return await getCurrentPosition(accuracy: accuracy);
      } catch (e) {
        toast(message: e.toString());
      }
    } else {
      toast(message: permission.message);
    }
    return null;
  }

  Future<InitMap> _loadMapStyle() async {
    try {
      Position? position = await checkPermission(LocationAccuracy.low);
      CameraPosition kGooglePlex = CameraPosition(
        target: LatLng(position!.latitude,
            position.longitude), // Use Google Maps LatLng directly
        zoom: 13,
      );
      String map_style =
          await rootBundle.loadString('assets/json/map_style.json');
      return InitMap(cameraPosition: kGooglePlex, map_style: map_style);
    } catch (e) {
      CameraPosition kGooglePlex = CameraPosition(
        target: LatLng(13.0843, 80.2705), // Use Google Maps LatLng directly
        zoom: 13,
      );
      return InitMap(cameraPosition: kGooglePlex, map_style: '');
    }
  }

  List<StepperData> _generateStepperData(int activeIndex) {
    return List.generate(journeyDetails.journeyDetails!.length, (index) {
      return StepperData(
        title: StepperText(
          '${journeyDetails.journeyDetails![index].status}',
          textStyle: TextStyle(
            color: index <= activeIndex
                ? HistoryTheme.secondaryColor
                : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: index <= activeIndex
            ? StepperText(
                '𝄜 ${journeyDetails.journeyDetails![index].createdOn}',
                textStyle: const TextStyle(color: Colors.grey))
            : null,
        iconWidget: GestureDetector(
          // onTap: () => activeIndexNotifier.value = index,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: index <= activeIndex
                  ? HistoryTheme.secondaryColor
                  : Colors.grey,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(
                  'assets/images/${journeyDetails.journeyDetails![index].icon}',
                  fit: BoxFit.scaleDown),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => historyBloc,
      child: BlocConsumer<HistoryBloc, HistoryState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GetJourneyDetailsState) {
            journeyDetails = state.journeyDetails;
            _addMarkersAndPolyline();
            print('journeyDetails${jsonEncode(journeyDetails)}');
            return SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Stack(
                  children: [
                    _buildMap(),
                    _buildInfoCards(),
                    if (journeyDetails.cancelPermission)
                      _buildCancellationButton(),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildMap() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: FutureBuilder<InitMap>(
            future: _mapStyleFuture,
            builder: (BuildContext context, AsyncSnapshot<InitMap> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return GoogleMap(
                  style: snapshot.data!.map_style,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: snapshot.data!.cameraPosition,
                  mapType: MapType.normal,
                  markers: markers, // Add markers
                  polylines: polylines, // Add polyline
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                );
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Positioned.fill(
      top: MediaQuery.of(context).size.height * 0.2,
      left: 24,
      right: 24,
      child: Column(
        children: [
          _buildDriverInfoCard(),
          const SizedBox(height: 10),
          _buildJourneyDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: const Color.fromARGB(255, 82, 58, 58).withOpacity(0.3)),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      color: HistoryTheme.lightBlack,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 9),
        child: Row(
          children: [
            const Image(image: AssetImage('assets/images/Oval.png'), width: 76),
            const SizedBox(width: 10),
            Expanded(child: _buildDriverDetails()),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetails() {
    return Column(
      children: [
        _buildDetailRow(
            'assets/images/deliveryvan_2.png', '${journeyDetails.driverName}'),
        _buildDetailRow('assets/images/Drive.png', 'Trucks with awnings'),
        _buildDetailRow('assets/images/dive.png',
            '${journeyDetails.totalWeight} ${journeyDetails.weightType}'),
        Row(
          children: [
            const Text('License plate:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            const SizedBox(width: 5),
            Text('${journeyDetails.plateNumber}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Image(image: AssetImage(imagePath), height: 16, width: 16),
          const SizedBox(width: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis),
                maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyDetailsCard() {
    return Expanded(
      child: SingleChildScrollView(
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: const Color.fromARGB(255, 82, 58, 58).withOpacity(0.3)),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          color: HistoryTheme.lightBlack,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Journey details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ValueListenableBuilder<int>(
                  valueListenable: activeIndexNotifier,
                  builder: (context, activeIndex, child) {
                    final stepperData = _generateStepperData(
                        journeyDetails.journeyDetails!.first.activeIndex ?? 0);
                    return AnotherStepper(
                      stepperList: stepperData,
                      stepperDirection: Axis.vertical,
                      iconWidth: 40,
                      iconHeight: 40,
                      activeBarColor: HistoryTheme.secondaryColor,
                      inActiveBarColor: Colors.grey,
                      verticalGap: 30,
                      activeIndex: activeIndex,
                      barThickness: 8,
                    );
                  },
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: HistoryTheme.lightBlack,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/CancelOrder', arguments: {
                "serviceBookingSno": widget.booking.serviceBookingSno
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HistoryTheme.primaryColor.withOpacity(0.2),
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: HistoryTheme.ashColor, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                    color: HistoryTheme.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

class StepInfo {
  final String title;
  final String subtitle;
  final String imagePath;

  StepInfo(this.title, this.subtitle, this.imagePath);
}

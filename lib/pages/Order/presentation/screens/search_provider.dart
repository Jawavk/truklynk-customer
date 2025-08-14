import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/Order/bloc/order_bloc.dart';
import 'package:truklynk/pages/Order/bloc/order_event.dart';
import 'package:truklynk/pages/Order/bloc/order_state.dart';
import 'package:truklynk/pages/Order/data/models/booking_status_model.dart';
import 'package:truklynk/pages/Order/data/models/map.dart';
import 'package:truklynk/pages/Order/presentation/constants/order_theme.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:truklynk/services/fire_base_service.dart';
import 'package:truklynk/utils/helper_functions.dart';
import 'package:truklynk/utils/helper_model.dart';

import '../../../History/data/models/booking_model.dart';

class SearchProviderScreen extends StatefulWidget {
  int serviceBookingId;
  DateTime createdOn;
  SearchProviderScreen(
      {super.key, required this.serviceBookingId, required this.createdOn});
  @override
  State<SearchProviderScreen> createState() => _SearchProviderScreenState();
}

extension ContextExtensions on BuildContext {
  OrderDataProvider get orderData =>
      Provider.of<OrderDataProvider>(this, listen: false);
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {
  final OrderBloc orderBloc = OrderBloc();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final List<double> _progressValues = [0.0, 0.0, 0.0, 0.0];
  Timer? _timer;
  Timer? _refreshTimer;
  int resumeIndex = 0;
  List<ServiceProviderList> serviceProviderList = [];
  Future<InitMap>? _mapStyleFuture;
  String displayText = '00:00';
  int selectedTripQuote = 0;
  final double dragSensitivity = 600;
  double sheetPosition = 0.55;
  late StreamSubscription<Map<String, dynamic>> _messageSubscription;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  FireBaseService fireBaseService =
      FireBaseService(); // Initialize directly, remove `late`
  bool _isTimerInitialized = false;

  @override
  void initState() {
    super.initState();
    print('widget.createdOn${widget.createdOn}');
    if (!_isTimerInitialized) {
      _timer = Timer.periodic(Duration(seconds: 15), (timer) {
        print(
            'Timer tick at ${DateTime.now()}: Calling _getUserDetails with forceSync: true');
        orderBloc
            .add(BookStatusEvent(serviceBookingId: widget.serviceBookingId));
      });
      _isTimerInitialized = true;
    }

    fireBaseService.firebaseInit().then((_) {
      // Add BLoC events after Firebase initialization
      orderBloc.add(BookStatusEvent(serviceBookingId: widget.serviceBookingId));
      orderBloc.add(StartTimer(widget.createdOn, const Duration(minutes: 10)));
      orderBloc.add(InitializeRealTimeSync(
        serviceBookingSno: widget.serviceBookingId,
        fireBaseService: fireBaseService,
      ));
    }).catchError((e) {
      print('Error initializing Firebase: $e');
    });
    _mapStyleFuture = _loadMapStyle();
    _startProgress(0);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _refreshTimer?.cancel();
    _timer?.cancel();

    orderBloc.close(); // Close the bloc when the widget is disposed
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fireBaseService =
        Provider.of<FireBaseService>(context, listen: false);
    _messageSubscription = fireBaseService.messageStream.listen((data) {
      info("Received data: $data");
      if (data.containsKey("quotation_status")) {
        if (data["quotation_status"] == 'Quotation' &&
            data.containsKey("serviceBookingId")) {
          String? serviceBookingIdString = data['serviceBookingId'];
          if (serviceBookingIdString != null) {
            try {
              int serviceBookingId = int.parse(serviceBookingIdString);
              info("serviceBookingId $serviceBookingId");
              orderBloc
                  .add(BookStatusEvent(serviceBookingId: serviceBookingId));
            } catch (e) {
              error("Failed to parse serviceBookingId: $e");
            }
          } else {
            error("serviceBookingId is null");
          }
        }
      } else if (data.containsKey("booking_status") &&
          data["booking_status"] == 'timeout') {
        Navigator.pushNamedAndRemoveUntil(
            context, '/BottomBar', (Route route) => false);
      }
    });
  }

  Future<InitMap> _loadMapStyle() async {
    try {
      Position? position = await checkPermission(LocationAccuracy.low);
      CameraPosition kGooglePlex = CameraPosition(
        target: LatLng(position!.latitude, position.longitude),
        zoom: 13,
      );
      String map_style =
          await rootBundle.loadString('assets/json/map_style.json');
      return InitMap(cameraPosition: kGooglePlex, map_style: map_style);
    } catch (e) {
      CameraPosition kGooglePlex = const CameraPosition(
        target: LatLng(13.0843, 80.2705),
        zoom: 13,
      );
      return InitMap(cameraPosition: kGooglePlex, map_style: '');
    }
  }

  Future<Position?> checkPermission(LocationAccuracy accuracy) async {
    CustomePermission permission = await checkGpsPermission();
    if (permission.status) {
      try {
        Position position = await getCurrentPosition(accuracy: accuracy);
        return position;
      } catch (e) {
        toast(message: e);
      }
    } else {
      toast(message: permission.message);
    }
    return null;
  }

  void _startProgress(int index) {
    if (index >= _progressValues.length) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progressValues[index] < 100) {
          _progressValues[index] += 2; // Adjust the increment as needed
        } else {
          _timer?.cancel();
          _startProgress(index + 1); // Start the next progress indicator
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, '/BottomBar', (Route route) => false);
        return false;
      },
      child: BlocProvider(
        create: (_) => orderBloc,
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is BookStatusState) {
                  serviceProviderList = state.serviceProviderList;
                  if (serviceProviderList.isNotEmpty) {
                    final bookingDetails =
                        serviceProviderList.first.bookingDetails;
                    final pickupLatLng = bookingDetails?.pickupLocation?.latlng;
                    final dropLatLng = bookingDetails?.dropLocation?.latlng;

                    if (pickupLatLng != null &&
                        pickupLatLng.latitude != null &&
                        pickupLatLng.longitude != null) {
                      const MarkerId markerId = MarkerId('pickup');
                      markers[markerId] = Marker(
                        markerId: markerId,
                        position: LatLng(
                            pickupLatLng.latitude!, pickupLatLng.longitude!),
                        icon: AssetMapBitmap('assets/images/pickup.png',
                            height: 24),
                      );
                      updateCameraPosition(LatLng(
                          pickupLatLng.latitude!, pickupLatLng.longitude!));
                    }

                    if (dropLatLng != null &&
                        dropLatLng.latitude != null &&
                        dropLatLng.longitude != null) {
                      const MarkerId markerId = MarkerId('drop');
                      markers[markerId] = Marker(
                        markerId: markerId,
                        position:
                            LatLng(dropLatLng.latitude!, dropLatLng.longitude!),
                        icon: AssetMapBitmap('assets/images/drop.png',
                            height: 24),
                      );
                      updateCameraPosition(
                          LatLng(dropLatLng.latitude!, dropLatLng.longitude!));
                    }
                  } else {
                    debugPrint("No service providers available.");
                  }
                }
                if (state is TimerRunning) {
                  displayText = state.remainingTime;
                } else {
                  // displayText = '00:00';
                }
                if (state is FetchPolyLineState) {
                  addPolyLine(state.polyLineSteps);
                }
                if (state is SelectQuoteState) {
                  selectedTripQuote = state.index;
                }
                if (state is DragState) {
                  sheetPosition = state.dragPosition;
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.50,
                        child: FutureBuilder<InitMap>(
                            future: _mapStyleFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<InitMap> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                return GoogleMap(
                                  myLocationButtonEnabled: true,
                                  zoomControlsEnabled: false,
                                  initialCameraPosition:
                                      snapshot.data!.cameraPosition,
                                  mapType: MapType.normal,
                                  markers: Set<Marker>.of(markers.values),
                                  polylines: Set<Polyline>.of(polylines.values),
                                  style: snapshot.data!.map_style,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    if (!_controller.isCompleted) {
                                      _controller.complete(controller);
                                      orderBloc.add(LoadingMap());
                                      setTwoPointCameraView();
                                    }
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text('No data available'));
                              }
                            })),
                    GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        sheetPosition -= details.delta.dy / dragSensitivity;
                        if (sheetPosition < 0.55) {
                          sheetPosition = 0.55;
                        }
                        if (sheetPosition > 0.95) {
                          sheetPosition = 0.95;
                        }
                        orderBloc.add(DragEvent(dragPosition: sheetPosition));
                      },
                      child: DraggableScrollableSheet(
                        initialChildSize: sheetPosition,
                        minChildSize: 0.55,
                        maxChildSize: 0.95,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: OrderTheme.blackColor,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26, blurRadius: 8.0),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      width: 40.0,
                                      height: 4.0,
                                      decoration: BoxDecoration(
                                        color: OrderTheme.whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Searching for quotation',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: OrderTheme.whiteColor),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                            color: OrderTheme.whiteColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Column(
                                          children: [
                                            Text(
                                              displayText,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: OrderTheme.blackColor),
                                            ),
                                            const Text(
                                              'Mins',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: OrderTheme.blackColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(
                                      children: List.generate(4, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.19,
                                                child: LinearProgressIndicator(
                                                  minHeight: 7,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color:
                                                      OrderTheme.secondaryColor,
                                                  backgroundColor:
                                                      OrderTheme.whiteColor,
                                                  value:
                                                      _progressValues[index] /
                                                          100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const SizedBox(height: 20),
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Trip Quotes',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: OrderTheme.whiteColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: serviceProviderList.length,
                                      itemBuilder: (context, index) {
                                        ServiceProviderList provider =
                                            serviceProviderList[index];
                                        return InkWell(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 14),
                                            child: Card(
                                              elevation: 5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      ClipOval(
                                                        child: Image.asset(
                                                          'assets/images/profile2.png', // Replace with your image path
                                                          height: 51,
                                                          width: 51,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${provider.serviceProviderName}', // Update according to your model
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: OrderTheme
                                                                    .whiteColor),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            children: [
                                                              if (provider.ratings!
                                                                          .overallRating !=
                                                                      null &&
                                                                  provider.ratings!
                                                                          .overallRating! >
                                                                      0) ...[
                                                                Row(
                                                                  children: [
                                                                    // Render full stars
                                                                    for (int i =
                                                                            1;
                                                                        i <=
                                                                            provider.ratings!.overallRating!.floor();
                                                                        i++)
                                                                      const Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .yellow,
                                                                        size:
                                                                            16,
                                                                      ),

                                                                    // Check if there’s a half star
                                                                    if (provider.ratings!.overallRating! -
                                                                            provider.ratings!.overallRating!.floor() >=
                                                                        0.5)
                                                                      const Icon(
                                                                        Icons
                                                                            .star_half,
                                                                        color: Colors
                                                                            .yellow,
                                                                        size:
                                                                            16,
                                                                      ),

                                                                    // Render empty stars if any
                                                                    for (int i = provider
                                                                            .ratings!
                                                                            .overallRating!
                                                                            .ceil();
                                                                        i < 5;
                                                                        i++)
                                                                      const Icon(
                                                                        Icons
                                                                            .star_border,
                                                                        color: Colors
                                                                            .yellow,
                                                                        size:
                                                                            16,
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                              const SizedBox(
                                                                  width: 8),
                                                              if (provider.price !=
                                                                      null &&
                                                                  provider.price >
                                                                      0) ...[
                                                                Text(
                                                                  '₹ ${provider.price}', // Update according to your model
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: OrderTheme
                                                                          .whiteColor),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ] else ...[
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: OrderTheme
                                                                            .whiteColor,
                                                                        width:
                                                                            2),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                  child: Text(
                                                                    '${provider.quotationStatus}',
                                                                    style: const TextStyle(
                                                                        color: OrderTheme
                                                                            .secondaryColor),
                                                                  ),
                                                                )
                                                              ],
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ]),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/ConfirmBooking',
                                                              arguments: {
                                                                'booking':
                                                                    provider, // or any DateTime value
                                                              }).then((_) {
                                                            orderBloc.add(
                                                                BookStatusEvent(
                                                                    serviceBookingId:
                                                                        widget
                                                                            .serviceBookingId));
                                                            orderBloc.add(StartTimer(
                                                                widget
                                                                    .createdOn,
                                                                const Duration(
                                                                    minutes:
                                                                        10)));
                                                          });
                                                        },
                                                        child: const Text(
                                                            'View',
                                                            style: TextStyle(
                                                                color: OrderTheme
                                                                    .whiteColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  _buildContinueButton(context),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  updateCameraPosition(LatLng? location) async {
    final GoogleMapController controller = await _controller.future;
    print('location $location');
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: location ?? const LatLng(12.9010, 80.2279),
      zoom: 13,
    )));
    Marker? pickup = markers[const MarkerId('pickup')];
    Marker? drop = markers[const MarkerId('drop')];
    if (pickup != null && drop != null) {
      orderBloc
          .add(FetchPolyLine(pickup: pickup.position, drop: drop.position));
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.white,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setTwoPointCameraView();
  }

  setTwoPointCameraView() async {
    final pickup = markers[const MarkerId('pickup')];
    final drop = markers[const MarkerId('drop')];

    if (pickup == null || drop == null) {
      print("Pickup or Drop marker is null");
      return;
    }

    LatLng centerPoint = LatLng(
      (pickup.position.latitude + drop.position.latitude) / 2,
      (pickup.position.longitude + drop.position.longitude) / 2,
    );

    double distance = calculateDistance(pickup.position, drop.position);
    double zoomLevel = getZoomLevel(distance);

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newLatLngZoom(centerPoint, zoomLevel));
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/CancelOrder',
              arguments: {"serviceBookingSno": widget.serviceBookingId});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: OrderTheme.whiteColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
              color: OrderTheme.cardBackground,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

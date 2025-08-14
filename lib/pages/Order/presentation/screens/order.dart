import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/Order/bloc/order_bloc.dart';
import 'package:truklynk/pages/Order/bloc/order_event.dart';
import 'package:truklynk/pages/Order/bloc/order_state.dart';
import 'package:truklynk/pages/Order/data/models/map.dart';
import 'package:truklynk/pages/Order/presentation/constants/order_theme.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:truklynk/utils/helper_functions.dart';
import 'package:truklynk/utils/helper_model.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

extension ContextExtensions on BuildContext {
  OrderDataProvider get orderData =>
      Provider.of<OrderDataProvider>(this, listen: false);
}

class _OrderScreenState extends State<OrderScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};

  TextEditingController pickingController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  FocusNode pickingFocusNode = FocusNode();
  FocusNode deliveryFocusNode = FocusNode();
  OrderBloc orderBloc = OrderBloc();
  bool isLocationInValid = true;
  Future<InitMap>? _mapStyleFuture;

  @override
  void initState() {
    if (context.orderData.getPickupLocation.latLng != null) {
      const MarkerId markerId = MarkerId('pickup');
      final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
              context.orderData.getPickupLocation.latLng!.latitude ?? 0,
              context.orderData.getPickupLocation.latLng!.longitude ?? 0),
          icon: AssetMapBitmap(
            'assets/images/pickup.png',
            height: 24,
          ));
      markers[markerId] = marker;
      pickingController.text = '${context.orderData.getPickupLocation.name}';
    }
    if (context.orderData.getDropLocation.latLng != null) {
      const MarkerId markerId = MarkerId('drop');
      final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
              context.orderData.getDropLocation.latLng!.latitude ?? 0,
              context.orderData.getDropLocation.latLng!.longitude ?? 0),
          icon: AssetMapBitmap(
            'assets/images/drop.png',
            height: 24,
          ));
      markers[markerId] = marker;
      deliveryController.text = '${context.orderData.getDropLocation.name}';
    }
    locationValidation();
    _mapStyleFuture = _loadMapStyle();
    super.initState();
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

  @override
  void dispose() {
    pickingController.dispose();
    deliveryController.dispose();
    pickingFocusNode.dispose();
    deliveryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => orderBloc,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            surfaceTintColor: OrderTheme.blackColor,
            backgroundColor: OrderTheme.blackColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'New Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          body: BlocConsumer<OrderBloc, OrderState>(listener: (context, state) {
            if (state is Suggestion) {
              if (state.location != null) {
                print('state.location ${state.location}');
                final MarkerId markerId =
                    MarkerId(state.isEditingPicking ? 'pickup' : 'drop');
                final Marker marker = Marker(
                    markerId: markerId,
                    position: state.location ?? const LatLng(0, 0),
                    icon: AssetMapBitmap(
                      'assets/images/${state.isEditingPicking ? 'pickup.png' : 'drop.png'}',
                      height: 24,
                    ));
                markers[markerId] = marker;
                updateCameraPosition(state.location);
                locationValidation();
              }

              if (state.isEditingPicking) {
                pickingController.text = state.name;
                const MarkerId markerId = MarkerId('pickup');
                context.orderData.addPickupLocation(
                    markers[markerId]!.position,
                    pickingController.text,
                    '${state.placeId}',
                    false,
                    state.city,
                    state.state,
                    state.country);
                FocusScope.of(context).unfocus();
              } else {
                deliveryController.text = state.name;
                const MarkerId markerId = MarkerId('drop');
                context.orderData.addDropLocation(
                    markers[markerId]!.position,
                    deliveryController.text,
                    '${state.placeId}',
                    false,
                    state.city,
                    state.state,
                    state.country);
                FocusScope.of(context).unfocus();
              }
            }
            if (state is CurrentLocation) {
              pickingController.text = state.name;
              if (state.location != null) {
                const MarkerId markerId = MarkerId('pickup');
                final Marker marker = Marker(
                    markerId: markerId,
                    position: state.location ?? const LatLng(0, 0),
                    icon: AssetMapBitmap(
                      'assets/images/pickup.png',
                      height: 24,
                    ));
                markers[markerId] = marker;
                updateCameraPosition(state.location);
                locationValidation();
                context.orderData.addPickupLocation(
                    markers[markerId]!.position,
                    pickingController.text,
                    '${state.placeId}',
                    false,
                    state.city,
                    state.state,
                    state.country);
              }
              FocusScope.of(context).unfocus();
            }

            if (state is FetchPolyLineState) {
              addPolyLine(state.polyLineSteps);
            }

            if (state is CheckPageValidState) {
              isLocationInValid = state.isCheckPageValid;
            }
          }, builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: pickingFocusNode.hasFocus ||
                                deliveryFocusNode.hasFocus
                            ? MediaQuery.of(context).size.height * 0.35
                            : MediaQuery.of(context).size.height * 0.55,
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
                                polylines: Set<Polyline>.of(polylines
                                    .values), // Pass the updated polylines
                                style: snapshot.data!.map_style,
                                onMapCreated: (GoogleMapController controller) {
                                  if (!_controller.isCompleted) {
                                    _controller.complete(controller);
                                    orderBloc.add(LoadOrderMap());
                                    setTwoPointCameraView();
                                  }
                                },
                              );
                            } else {
                              return const Center(
                                  child: Text('No data available'));
                            }
                          },
                        )),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(
                        height: pickingFocusNode.hasFocus ||
                                deliveryFocusNode.hasFocus
                            ? MediaQuery.of(context).size.height * 0.1
                            : MediaQuery.of(context).size.height * 0.45,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Card(
                              color: OrderTheme.blackColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/pick-drop.png',
                                          height: 90,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      OrderTheme.cardBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            pickingController,
                                                        focusNode:
                                                            pickingFocusNode,
                                                        onChanged:
                                                            (query) async {
                                                          // List<Location> locations = await locationFromAddress(query);
                                                          // print('query$locations');
                                                          orderBloc.add(
                                                              FetchSuggestions(
                                                                  query));
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              'Pickup Location',
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      8.0),
                                                          suffixIcon:
                                                              pickingController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .clear,
                                                                          color:
                                                                              Colors.white),
                                                                      onPressed:
                                                                          () {
                                                                        clearPickUpLocation();
                                                                      },
                                                                    )
                                                                  : null,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      OrderTheme.cardBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            deliveryController,
                                                        focusNode:
                                                            deliveryFocusNode,
                                                        onChanged: (query) {
                                                          orderBloc.add(
                                                              FetchSuggestions(
                                                                  query));
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              'Drop Location',
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12,
                                                                  horizontal:
                                                                      8.0),
                                                          suffixIcon:
                                                              deliveryController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .clear,
                                                                          color:
                                                                              Colors.white),
                                                                      onPressed:
                                                                          () {
                                                                        clearDropLocation();
                                                                      },
                                                                    )
                                                                  : null,
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  color: OrderTheme.blackColor),
                              child: Visibility(
                                visible: pickingFocusNode.hasFocus ||
                                    deliveryFocusNode.hasFocus,
                                replacement: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!isLocationInValid) {
                                        Navigator.pushNamed(context, '/Pickup');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !isLocationInValid
                                          ? OrderTheme.whiteColor
                                          : OrderTheme.primaryColor,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Next',
                                      style: TextStyle(
                                        color: !isLocationInValid
                                            ? OrderTheme.primaryColor
                                            : OrderTheme.whiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Container(
                                  height: 300,
                                  color: Colors.black,
                                  child: Column(
                                    children: [
                                      if (pickingFocusNode.hasFocus) ...[
                                        ListTile(
                                          title: const Text(
                                              'Pick current location'),
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(pickingFocusNode);
                                            getLocation();
                                          },
                                        ),
                                      ],
                                      if (state is! OrderLoaded &&
                                          state is! OrderLoading) ...[
                                        const Expanded(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                SizedBox(height: 40),
                                                Image(
                                                  image: AssetImage(
                                                      'assets/images/search.png'),
                                                  width: 80,
                                                ),
                                                SizedBox(height: 10),
                                                Text('Search for location',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (state is OrderLoaded &&
                                          state.suggestions.isNotEmpty) ...[
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: state.suggestions.length,
                                            itemBuilder: (context, index) {
                                              Suggestion suggestion =
                                                  state.suggestions[index];
                                              return ListTile(
                                                title: Text(suggestion.name),
                                                onTap: () {
                                                  print(
                                                      'suggestionlocation${suggestion.location?.latitude}${suggestion.location?.longitude}');
                                                  orderBloc.add(SuggestionEvent(
                                                      suggestion.name,
                                                      suggestion.location,
                                                      suggestion.placeId,
                                                      pickingFocusNode.hasFocus,
                                                      suggestion.city,
                                                      suggestion.state,
                                                      suggestion.country));
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ] else if (state is OrderLoading) ...[
                                        const Expanded(
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      ] else if (state is OrderLoaded &&
                                          state.suggestions.isEmpty) ...[
                                        const Expanded(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                SizedBox(height: 40),
                                                Image(
                                                  image: AssetImage(
                                                      'assets/images/search.png'),
                                                  width: 80,
                                                ),
                                                SizedBox(height: 10),
                                                Text('No result found',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (state is OrderError) ...[
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Error: ${state.message}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          })),
    );
  }

  updateCameraPosition(LatLng? location) async {
    final GoogleMapController controller = await _controller.future;
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

  getLocation() async {
    Position? position = await checkPermission(LocationAccuracy.high);
    if (position != null) {
      List<Placemark> currentLocation = await getPlacemarkFromCoordinates(
          latitude: position.latitude, longitude: position.longitude);
      if (currentLocation.isNotEmpty) {
        Placemark placeMark = currentLocation[0];
        String? subLocality = placeMark.subLocality;
        String? locality = placeMark.locality;
        orderBloc.add(CurrentLocationEvent(
            '$subLocality,$locality',
            LatLng(position.latitude, position.longitude),
            'currentLocation',
            pickingFocusNode.hasFocus,
            placeMark.subLocality,
            placeMark.locality,
            placeMark.country));
      }
    }
  }

  locationValidation() {
    Marker? pickup = markers[const MarkerId('pickup')];
    Marker? drop = markers[const MarkerId('drop')];
    orderBloc.add(CheckPageValid(
        pageInvalid: (pickup != null ? pickup.position.latitude == 0 : true) ||
            (drop != null ? drop.position.latitude == 0 : true)));
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.white,
      points: polylineCoordinates,
      width: 4,
    );
    setState(() {
      polylines[id] = polyline; // Update the polylines map
    });
    setTwoPointCameraView(); // Adjust camera to fit the polyline
  }

  void setTwoPointCameraView() async {
    final pickup = markers[const MarkerId('pickup')];
    final drop = markers[const MarkerId('drop')];

    if (pickup == null || drop == null) {
      print("Pickup or Drop marker is null");
      return;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(pickup.position.latitude, drop.position.latitude),
        min(pickup.position.longitude, drop.position.longitude),
      ),
      northeast: LatLng(
        max(pickup.position.latitude, drop.position.latitude),
        max(pickup.position.longitude, drop.position.longitude),
      ),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50)); // Adjust padding as needed
  }

  clearPickUpLocation() {
    pickingController.clear();
    markers.remove(const MarkerId('pickup'));
    context.orderData.resetPickupLocations();
    locationValidation();
  }

  clearDropLocation() {
    deliveryController.clear();
    markers.remove(const MarkerId('drop'));
    context.orderData.resetDropupLocations();
    locationValidation();
  }
}

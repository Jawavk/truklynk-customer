import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/Order/data/models/block_service_providers_model.dart';
import 'package:truklynk/pages/Order/data/models/booking_status_model.dart';
import 'package:truklynk/pages/Order/data/models/conform_booking_model.dart';
import 'package:truklynk/pages/Order/data/models/enum.dart';
import 'package:truklynk/pages/Order/data/models/order_model.dart';
import 'package:truklynk/pages/Order/data/models/service_provider_schedule_model.dart';
import 'package:truklynk/pages/Order/data/models/subcategory_model.dart';
import 'package:truklynk/pages/Order/data/repository/order_repo.dart';
import 'package:truklynk/utils/helper_functions.dart';
import '../../../services/sockerService.dart';
import 'order_event.dart';
import 'order_state.dart';
import 'package:http/http.dart' as http;

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderRepo orderRepo = OrderRepo();
  Timer? _timer;
  List<String> goodsList = [];
  final SocketService socketService = SocketService();
  Set<Polyline> _polylines = {};
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  StreamSubscription<Map<String, dynamic>>? _fcmSubscription;

  OrderBloc() : super(OrderInitial()) {
    on<SuggestionEvent>(_onSuggestionEvent);
    on<FetchSuggestions>(_onFetchLocation);
    on<FetchPolyLine>(_onFetchPolyLine);
    on<DatePickEvent>(_onDatePickEvent);
    on<FetchVehicleEvent>(_onFetchVehicle);
    on<FetchWeightEvent>(_onFetchWeightEvent);
    on<ChangeWeightEvent>(_onWeightPickEvent);
    on<ChangeVehicleEvent>(_onChangeVehicleEvent);
    on<ChangeNameEvent>(_onChangeNameEvent);
    on<ChangeNumberEvent>(_onChangeNumberEvent);
    on<CurrentLocationEvent>(_onCurrentLocationEvent);
    on<CheckPageValid>(_onCheckPageValid);
    on<BookVehicleEvent>(_onBookVehicle);
    on<BookStatusEvent>(_onGetBookingStatus);
    on<SearchLoadingEvent>(_onSearchLoading);
    on<StartTimer>(_onStartTimer);
    on<StopTimer>(_onStopTimer);
    on<UpdateTimer>(_onUpdateTimer);
    on<SelectQuoteEvent>(_onSelectedQuote);
    on<DragEvent>(_onDrag);
    on<QuoteConfirmationEvent>(_onQuoteConfirmation);
    on<BlockServiceProviderEvent>(_onBlockServiceProviders);
    on<RejectServiceProviderEvent>(_onRejectServiceProvider);
    on<LoadingMap>((event, emit) {
      // Handle the LoadingMap event
      emit(MapLoadingState());
    });
    on<HandleSyncEvent>(_onHandleSyncEvent);
  }

  Future<void> _onSuggestionEvent(
      SuggestionEvent event, Emitter<OrderState> emit) async {
    LatLng? result = await orderRepo.getLatLng({'query': event.placeId});
    print('result$result');
    emit(Suggestion(
        name: event.name,
        location: result,
        placeId: event.placeId,
        isEditingPicking: event.isEditingPicking,
        city: event.city,
        state: event.state,
        country: event.country));
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
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

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  Future<void> _onCurrentLocationEvent(
      CurrentLocationEvent event, Emitter<OrderState> emit) async {
    emit(CurrentLocation(
        name: event.name,
        location: event.location,
        placeId: event.placeId,
        isEditingPicking: event.isEditingPicking,
        city: event.city,
        state: event.state,
        country: event.country));
  }

  Future<void> _onFetchLocation(
      FetchSuggestions event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      print('event${event.query}');
      List<Suggestion> result =
          await orderRepo.getSuggestion({'query': event.query});
      print('resultss$result');
      emit(OrderLoaded(result));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchPolyLine(
      FetchPolyLine event, Emitter<OrderState> emit) async {
    const apiKey = 'AIzaSyCq3n0PuZCtun6j0kiLnprf0mEqgQOvGls';

    LatLng? origin = event.pickup;
    LatLng? destination = event.drop;

    double? originLat = origin?.latitude;
    double? originLng = origin?.longitude;
    double? destinationLat = destination?.latitude;
    double? destinationLng = destination?.longitude;

    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$originLat,$originLng'
        '&destination=$destinationLat,$destinationLng'
        '&key=$apiKey';
    print('url$url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] != 'OK') {
          print('Error: ${responseBody['status']}');
          return;
        }

        if (responseBody['routes'] != null &&
            responseBody['routes'].isNotEmpty) {
          final String encodedPolyline =
              responseBody['routes'][0]['overview_polyline']['points'];

          final List<LatLng> decodedPolyline = _decodePolyline(encodedPolyline);
          print('Encoded Polyline: $encodedPolyline');
          print('Decoded Points: $decodedPolyline');
          emit(FetchPolyLineState(
              polyLineSteps: decodedPolyline)); // Emit the state
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<void> _onHandleSyncEvent(
      HandleSyncEvent event, Emitter<OrderState> emit) async {
    final eventData = event.eventData;
    print('Handling sync event: $eventData');

    if (eventData['event_type'] == 'quotation_update' ||
        eventData['event_type'] == 'booking_status') {
      // Refresh booking status
      final serviceBookingSno = eventData['service_booking_sno'];
      if (serviceBookingSno != null) {
        add(BookStatusEvent(serviceBookingId: serviceBookingSno));
      }
    }
  }

  Future<void> _onDatePickEvent(
      DatePickEvent event, Emitter<OrderState> emit) async {
    emit(FetchDateState(dateTime: event.dateTime));
  }

  Future<void> _onFetchVehicle(
      FetchVehicleEvent event, Emitter<OrderState> emit) async {
    VehicleModel result =
        await orderRepo.getSubCategory({'category_sno': event.categorySno});
    if (result.isSuccess ?? false) {
      emit(FetchVehicleState(vehicleList: result.vehicle));
    } else {
      emit(Message(message: result.error, code: 0));
    }
  }

  Future<void> _onFetchWeightEvent(
      FetchWeightEvent event, Emitter<OrderState> emit) async {
    EnumModel result = await orderRepo.getEnum({'clientService': "WEIGHT"});
    if (result.isSuccess ?? false) {
      emit(FetchWeightState(enumModelEnum: result.enumModelEnum));
    } else {
      emit(Message(message: result.error, code: 0));
    }
  }

  Future<void> _onWeightPickEvent(
      ChangeWeightEvent event, Emitter<OrderState> emit) async {
    emit(ChangeWeightState(value: event.value));
  }

  Future<void> _onChangeNameEvent(
      ChangeNameEvent event, Emitter<OrderState> emit) async {
    emit(ChangeNameState(name: event.name));
  }

  Future<void> _onChangeNumberEvent(
      ChangeNumberEvent event, Emitter<OrderState> emit) async {
    emit(ChangeNumberState(phoneNumber: event.phoneNumber));
  }

  Future<void> _onChangeVehicleEvent(
      ChangeVehicleEvent event, Emitter<OrderState> emit) async {
    emit(ChangeVehicleState(index: event.index));
  }

  Future<void> _onCheckPageValid(
      CheckPageValid event, Emitter<OrderState> emit) async {
    emit(CheckPageValidState(isCheckPageValid: event.pageInvalid));
  }

  Future<void> _onBookVehicle(
      BookVehicleEvent event, Emitter<OrderState> emit) async {
    DateTime createdOn = DateTime.now();
    print('events${jsonEncode(event.userProfileSno)}');
    Map<String, dynamic> data = {
      "booking_type": "Schedule",
      "booking_person": event.userProfileSno,
      "sub_category_sno": event.pickupInfo.vehicleId,
      "landmark": "",
      // "contact_info": event.pickupInfo.contactInfo,
      "contact_info": {
        "name": event.pickupInfo.name,
        "phone": event.pickupInfo.phoneNumber
      },
      "price": 0,
      "pickup_location": {
        "address": event.pickup.name,
        "latlng": event.pickup.latLng!.toJson(),
        "city": event.pickup.city,
        "state": event.pickup.state,
        "country": event.pickup.country,
        "landmark": "",
        "contact_info": ""
      },
      "drop_location": {
        "address": event.drop.name,
        "city": event.drop.city,
        "state": event.drop.state,
        "country": event.drop.country,
        "latlng": event.drop.latLng!.toJson(),
        "landmark": "",
        "contact_info": ""
      },
      "types_of_goods": event.pickupInfo.items,
      "distance": haversineDistance(
          event.pickup.latLng!.latitude ?? 0,
          event.pickup.latLng!.longitude ?? 0,
          event.drop.latLng!.latitude ?? 0,
          event.drop.latLng!.longitude ?? 0),
      "lat": event.pickup.latLng!.latitude,
      "lng": event.pickup.latLng!.longitude,
      "name": event.userName,
      "booking_time": event.pickupInfo.pickupDate.toString(),
      "category_name": "Long Trip",
      "weight_type_sno": event.pickupInfo.weightTypeSno,
      "weight_of_goods": event.pickupInfo.totalWeight,
      "created_on": createdOn.toString(),
      "notes": event.pickupInfo.notes
    };
    print('datasss$data');
    ServiceProviderScheduleModel result = await orderRepo.bookVehicle(data);
    if (result.isSuccess) {
      if (result.json != null &&
          result.json!.isNotEmpty &&
          result.json!.first.searchserviceproviderschedule!.first
                  .serviceBookingId !=
              null) {
        emit(BookVehicleState(
            serviceBookingId: result.json!.first.searchserviceproviderschedule!
                    .first.serviceBookingId ??
                0,
            createdOn: createdOn));
      } else if (result
              .json!.first.searchserviceproviderschedule!.first.isNoResult ??
          false) {
        // emit(Message(message: "Service provider not Available We will contact you Soon!.", code: 0));
        emit(ServiceUnavailableState(
            message:
                "Service provider not available. We will contact you soon!"));
      } else {
        emit(Message(message: "please try again", code: 0));
      }
    } else {
      emit(Message(message: "please try again", code: 0));
    }
  }

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    // Convert degrees to radians
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    // Distance in kilometers
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  Future<void> _onGetBookingStatus(
      BookStatusEvent event, Emitter<OrderState> emit) async {
    BookingStatusModel result = await orderRepo
        .getBookingStatus({'service_booking_sno': event.serviceBookingId});
    if (result.isSuccess) {
      final providers = result.json!.first.serviceProviderList ?? [];
      info(
          "Adding service providers: ${providers.length}"); // Log to see the count
      emit(BookStatusState(serviceProviderList: providers));
    }
  }

  Future<void> _onSearchLoading(
      SearchLoadingEvent event, Emitter<OrderState> emit) async {
    emit(SearchLoadingState(
        searching: event.searching, searchFor: event.searchFor));
  }

  Future<void> _onStartTimer(StartTimer event, Emitter<OrderState> emit) async {
    final endTime = event.startTime.add(event.duration);
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(endTime)) {
        add(StopTimer());
      } else {
        final remaining = endTime.difference(now);
        add(UpdateTimer(remaining));
      }
    });
  }

  void _onStopTimer(StopTimer event, Emitter<OrderState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(TimerFinished());
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<OrderState> emit) {
    final minutes = event.remaining.inMinutes;
    final seconds = event.remaining.inSeconds % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    emit(TimerRunning(remainingTime: formattedTime));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onSelectedQuote(
      SelectQuoteEvent event, Emitter<OrderState> emit) async {
    emit(SelectQuoteState(index: event.index));
  }

  Future<void> _onDrag(DragEvent event, Emitter<OrderState> emit) async {
    emit(DragState(dragPosition: event.dragPosition));
  }

  Future<void> _onQuoteConfirmation(
      QuoteConfirmationEvent event, Emitter<OrderState> emit) async {
    ConformBookingModel result = await orderRepo.quoteConfirmation({
      'service_booking_sno': event.service_booking_sno,
      "service_provider_sno": event.service_provider_sno,
      "vehicle_sno": event.vehicle_sno,
      "user_profile_sno": event.user_profile_sno,
      "driver_user_profile_sno": event.driver_user_profile_sno,
      "price": event.price,
      "updated_on": event.updated_on,
      "registering_type": event.registering_type
    });
    if (result.isSuccess) {
      emit(BookingSuccess());
    }
  }

  Future<void> _onRejectServiceProvider(
      RejectServiceProviderEvent event, Emitter<OrderState> emit) async {
    ConformBookingModel result = await orderRepo.quoteConfirmation({
      "service_provider_quotation_sno": event.service_provider_quotation_sno,
      "quotation_status_name": event.quotation_status_name,
      "driver_user_profile_sno": event.driver_user_profile_sno
    });
    if (result.isSuccess) {
      emit(RejectSuccess());
    }
  }

  Future<void> _onBlockServiceProviders(
      BlockServiceProviderEvent event, Emitter<OrderState> emit) async {
    BlockServiceProvidersModel result = await orderRepo.blockServiceProvider({
      "service_provider_quotation_sno": event.service_provider_quotation_sno,
      "service_provider_sno": event.service_provider_sno,
      "users_sno": event.users_sno,
      "created_on": event.created_on,
    });
    if (result.isSuccess) {
      emit(BlockServiceProviderState());
    }
  }
}

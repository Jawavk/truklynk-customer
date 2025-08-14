import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/History/data/models/booking_cancel_reason_model.dart';
import 'package:truklynk/pages/Order/data/models/order_model.dart';
import 'package:truklynk/pages/Order/providers/order_model.dart';

import '../../../services/fire_base_service.dart';

abstract class OrderEvent {}

class OrderSearchRequested extends OrderEvent {
  OrderSearchRequested();

  @override
  List<Object> get props => [];
}

class ToggleEditModeEvent extends OrderEvent {
  final String field;

  ToggleEditModeEvent(this.field);
}

class LoadOrderMap extends OrderEvent {}

class LoadingMap extends OrderEvent {}

class UpdateOrderLocation extends OrderEvent {
  final LatLng location;

  UpdateOrderLocation(this.location);
}

class AddOrderMarker extends OrderEvent {
  final LatLng position;
  final String markerId;

  AddOrderMarker(this.position, this.markerId);
}

class InitializeSocketService extends OrderEvent {
  InitializeSocketService();
}

class InitializeRealTimeSync extends OrderEvent {
  final int serviceBookingSno;
  final FireBaseService fireBaseService;

  InitializeRealTimeSync({
    required this.serviceBookingSno,
    required this.fireBaseService,
  });
}

class HandleSyncEvent extends OrderEvent {
  final Map<String, dynamic> eventData;

  HandleSyncEvent(this.eventData);
}

class GetOrderDirections extends OrderEvent {
  final LatLng? pickuplocation;
  final LatLng? droplocation; // LatLng object

  GetOrderDirections(
      this.pickuplocation, this.droplocation); // Accept a LatLng object
}

class FetchSuggestions extends OrderEvent {
  final String query;

  FetchSuggestions(this.query);
}

class SuggestionEvent extends OrderEvent {
  final String name;
  final LatLng? location;
  final String? placeId;
  final bool isEditingPicking;
  final String? city; // City name
  final String? state; // State name
  final String? country;
  SuggestionEvent(this.name, this.location, this.placeId, this.isEditingPicking,
      this.city, this.state, this.country);
}

class CurrentLocationEvent extends OrderEvent {
  final String name;
  final LatLng? location;
  final String? placeId;
  final bool isEditingPicking;
  final String? city; // City name
  final String? state; // State name
  final String? country;
  CurrentLocationEvent(this.name, this.location, this.placeId,
      this.isEditingPicking, this.city, this.state, this.country);
}

class FetchPolyLine extends OrderEvent {
  final LatLng pickup;
  final LatLng drop;
  FetchPolyLine({required this.pickup, required this.drop});
}

class DatePickEvent extends OrderEvent {
  final DateTime dateTime;
  DatePickEvent({required this.dateTime});
}

class FetchVehicleEvent extends OrderEvent {
  final int categorySno;
  FetchVehicleEvent({required this.categorySno});
}

class FetchWeightEvent extends OrderEvent {
  FetchWeightEvent();
}

class ChangeNameEvent extends OrderEvent {
  final String? name;
  ChangeNameEvent({required this.name});
}

class ChangeNumberEvent extends OrderEvent {
  final String? phoneNumber;
  ChangeNumberEvent({required this.phoneNumber});
}

class ChangeWeightEvent extends OrderEvent {
  final String? value;
  ChangeWeightEvent({required this.value});
}

class ChangeVehicleEvent extends OrderEvent {
  final int index;
  ChangeVehicleEvent({required this.index});
}

class CheckPageValid extends OrderEvent {
  final bool pageInvalid;
  CheckPageValid({required this.pageInvalid});
}

class BookVehicleEvent extends OrderEvent {
  Location pickup;
  Location drop;
  PickUpData pickupInfo;
  String userName;
  String userProfileSno;
  BookVehicleEvent(
      {required this.pickup,
      required this.drop,
      required this.pickupInfo,
      required this.userName,
      required this.userProfileSno});
}

class BookStatusEvent extends OrderEvent {
  int serviceBookingId;
  BookStatusEvent({required this.serviceBookingId});
}

class SearchLoadingEvent extends OrderEvent {
  bool searching;
  int searchFor;
  SearchLoadingEvent({required this.searching, required this.searchFor});
}

class StartTimer extends OrderEvent {
  final DateTime startTime;
  final Duration duration;

  StartTimer(this.startTime, this.duration);
}

class StopTimer extends OrderEvent {}

class UpdateTimer extends OrderEvent {
  final Duration remaining;
  UpdateTimer(this.remaining);
}

class SelectQuoteEvent extends OrderEvent {
  int index;
  SelectQuoteEvent({required this.index});
}

class DragEvent extends OrderEvent {
  double dragPosition;
  DragEvent({required this.dragPosition});
}

class QuoteConfirmationEvent extends OrderEvent {
  int? service_booking_sno;
  int? service_provider_sno;
  int? vehicle_sno;
  int? user_profile_sno;
  int? driver_user_profile_sno;
  dynamic price;
  String? updated_on;
  String? registering_type;

  QuoteConfirmationEvent({
    this.service_booking_sno,
    this.service_provider_sno,
    this.vehicle_sno,
    this.user_profile_sno,
    this.driver_user_profile_sno,
    this.price,
    this.updated_on,
    this.registering_type,
  });
}

class BlockServiceProviderEvent extends OrderEvent {
  int service_provider_quotation_sno;
  int service_provider_sno;
  int users_sno;
  String created_on;
  BlockServiceProviderEvent(
      {required this.service_provider_quotation_sno,
      required this.service_provider_sno,
      required this.users_sno,
      required this.created_on});
}

class CancelBooking extends OrderEvent {
  CancelBookingModel cancelBooking;
  CancelBooking({required this.cancelBooking});
}

class RejectServiceProviderEvent extends OrderEvent {
  int service_provider_quotation_sno;
  String quotation_status_name;
  dynamic driver_user_profile_sno;
  RejectServiceProviderEvent(
      {required this.service_provider_quotation_sno,
      required this.quotation_status_name,
      required this.driver_user_profile_sno});
}

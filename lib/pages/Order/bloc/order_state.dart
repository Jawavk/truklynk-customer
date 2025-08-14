import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/Order/data/models/booking_status_model.dart';
import 'package:truklynk/pages/Order/data/models/enum.dart';
import 'package:truklynk/pages/Order/data/models/subcategory_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class MapLoadingState extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Suggestion> suggestions; // List of Suggestion objects

  OrderLoaded(this.suggestions);
}

class SocketServiceInitialized extends OrderState {}

class QuotationSubscriptionSuccess extends OrderState {
  final int serviceBookingId;

  QuotationSubscriptionSuccess({required this.serviceBookingId});

  @override
  List<Object?> get props => [serviceBookingId];
}

class QuotationUpdateReceived extends OrderState {
  final Map<String, dynamic> data;

  QuotationUpdateReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class EditModeState extends OrderState {
  final bool isEditingPicking;
  final bool isEditingDelivery;

  EditModeState({
    required this.isEditingPicking,
    required this.isEditingDelivery,
  });
}

class ServiceUnavailableState extends OrderState {
  final String message;
  ServiceUnavailableState({required this.message});
  @override
  List<Object?> get props => [message];
}

class Suggestion extends OrderState {
  final String name;
  final LatLng? location;
  final String? placeId;
  final bool isEditingPicking;
  final String? city; // City name
  final String? state; // State name
  final String? country;

  Suggestion(
      {required this.name,
      required this.location,
      required this.placeId,
      required this.isEditingPicking,
      required this.city,
      required this.state,
      required this.country});
}

class CurrentLocation extends OrderState {
  final String name;
  final LatLng? location;
  final String? placeId;
  final bool isEditingPicking;
  final String? city; // City name
  final String? state; // State name
  final String? country;
  CurrentLocation(
      {required this.name,
      required this.location,
      required this.placeId,
      required this.isEditingPicking,
      required this.city,
      required this.state,
      required this.country});
}

class OrderLoading extends OrderState {}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);

  @override
  List<Object> get props => [message];
}

class FetchPolyLineState extends OrderState {
  final List<LatLng> polyLineSteps; // List of Suggestion objects
  FetchPolyLineState({required this.polyLineSteps});
}

class FetchDateState extends OrderState {
  final DateTime dateTime; // List of Suggestion objects
  FetchDateState({required this.dateTime});
}

class FetchContactState extends OrderState {
  final String name;
  final String phoneNumber; // List of Suggestion objects
  FetchContactState({required this.name, required this.phoneNumber});
}

class FetchVehicleState extends OrderState {
  final List<Vehicle>? vehicleList; // List of Suggestion objects
  FetchVehicleState({required this.vehicleList});
}

class FetchWeightState extends OrderState {
  final List<Enum>? enumModelEnum; // List of Suggestion objects
  FetchWeightState({required this.enumModelEnum});
}

class ChangeWeightState extends OrderState {
  final String? value;
  ChangeWeightState({required this.value});
}

class ChangeNameState extends OrderState {
  final String? name;
  ChangeNameState({required this.name});
}

class ChangeNumberState extends OrderState {
  final String? phoneNumber;
  ChangeNumberState({required this.phoneNumber});
}

class ChangeVehicleState extends OrderState {
  final int index;
  ChangeVehicleState({required this.index});
}

class Message extends OrderState {
  final String? message;
  final int? code;
  Message({required this.message, required this.code});
}

class CheckPageValidState extends OrderState {
  final bool isCheckPageValid;
  CheckPageValidState({required this.isCheckPageValid});
}

class BookVehicleState extends OrderState {
  int serviceBookingId;
  DateTime createdOn;
  BookVehicleState({required this.serviceBookingId, required this.createdOn});
}

class BookStatusState extends OrderState {
  List<ServiceProviderList> serviceProviderList;
  LatLng? location;
  BookStatusState({required this.serviceProviderList, this.location});
}

class SearchLoadingState extends OrderState {
  bool searching;
  int searchFor;
  SearchLoadingState({required this.searching, required this.searchFor});
}

class TimerRunning extends OrderState {
  String remainingTime;

  TimerRunning({required this.remainingTime});
}

class TimerFinished extends OrderState {}

class SelectQuoteState extends OrderState {
  int index;
  SelectQuoteState({required this.index});
}

class DragState extends OrderState {
  double dragPosition;
  DragState({required this.dragPosition});
}

class BookingSuccess extends OrderState {
  BookingSuccess();
}

class BlockServiceProviderState extends OrderState {
  BlockServiceProviderState();
}

class CancelBookingState extends OrderState {
  CancelBookingState();
}

class RejectSuccess extends OrderState {
  RejectSuccess();
}

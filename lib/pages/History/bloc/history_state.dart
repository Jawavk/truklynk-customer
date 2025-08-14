import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_reason_model.dart';
import 'package:truklynk/pages/History/data/models/journey_details.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {
  final bool hasReachedMax;
  HistoryLoading({this.hasReachedMax = false});
}

class Message extends HistoryState {
  final String? message;
  final int? code;
  Message({required this.message, required this.code});
}

class HistoryLoaded extends HistoryState {
  List<Booking> BookingList;
  HistoryLoaded({required this.BookingList});
}

class FetchCancelReasonState extends HistoryState {
  List<CancelReason> cancelReasonList;
  FetchCancelReasonState({required this.cancelReasonList});
}

class CancelBookingState extends HistoryState {
  CancelBookingState();
}

class GetJourneyDetailsState extends HistoryState {
  JourneyDetails journeyDetails;
  GetJourneyDetailsState({required this.journeyDetails});
}

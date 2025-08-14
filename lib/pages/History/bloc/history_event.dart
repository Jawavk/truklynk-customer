import 'package:truklynk/pages/History/data/models/booking_cancel_reason_model.dart';

import '../../Order/data/models/order_model.dart';
import '../../Order/providers/order_model.dart';

abstract class HistoryEvent {}

class FetchHistory extends HistoryEvent {
  int userProfileSno;
  int status;
  int skip;
  int limits;
  FetchHistory(
      {required this.userProfileSno,
      required this.status,
      required this.skip,
      required this.limits});
}

class BookQuotationEvent extends HistoryEvent {
  int serviceBookingSno;
  double lat;
  double lng;
  int bookingPersonSno;
  int subCategorySno;
  BookQuotationEvent(
      {required this.serviceBookingSno,
      required this.lat,
      required this.lng,
      required this.bookingPersonSno,
      required this.subCategorySno});
}

class FetchCancelReason extends HistoryEvent {
  FetchCancelReason();
}

class CancelBooking extends HistoryEvent {
  CancelBookingModel cancelBooking;
  CancelBooking({required this.cancelBooking});
}

class GetJourneyDetails extends HistoryEvent {
  int service_booking_sno;
  GetJourneyDetails({required this.service_booking_sno});
}

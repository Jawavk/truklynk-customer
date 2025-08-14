import 'package:truklynk/pages/History/data/models/booking_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class BookingState extends HomeState {
  List<Booking> BookingList;
  BookingState({required this.BookingList});
}

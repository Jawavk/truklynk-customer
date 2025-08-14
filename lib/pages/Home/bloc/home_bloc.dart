import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/Home/bloc/home_event.dart';
import 'package:truklynk/pages/Home/bloc/home_state.dart';
import 'package:truklynk/pages/Home/data/repository/home_repo.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeRepo homeRepo = HomeRepo();

  HomeBloc() : super(HomeInitial()) {
    on<FetchBooking>(_onGetBooking);
  }

  Future<void> _onGetBooking(
      FetchBooking event, Emitter<HomeState> emit) async {
    BookingModel result = await homeRepo.getHistory({
      "userProfileSno": event.userProfileSno,
      "status": event.status == 0 ? '{"Processing"}' : {},
      "skip": event.skip,
      "limits": event.limits
    });

    print("_onGetBooking ${jsonEncode(result)}");

    if (result.isSuccess ?? false) {
      // Filter out any bookings that are completely null/empty
      List<Booking> validBookings = (result.json ?? [])
          .where((booking) =>
              booking != null &&
              (booking.serviceBookingSno != null ||
                  booking.categoryName != null ||
                  booking.bookingStatusName != null))
          .toList();
      print("validBookings$validBookings");
      emit(BookingState(BookingList: validBookings));
    } else {
      emit(BookingState(BookingList: []));
    }
  }
}

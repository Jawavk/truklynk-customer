import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_booking_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_reason_model.dart';
import 'package:truklynk/pages/History/data/models/journey_details.dart';
import 'package:truklynk/pages/History/data/repository/history_repo.dart';
import '../../Order/data/models/quotation_status_model.dart';
import '../../Order/data/models/quotation_status_model.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryRepo historyRepo = HistoryRepo();

  HistoryBloc() : super(HistoryInitial()) {
    on<FetchHistory>(_onGetHistory);
    on<FetchCancelReason>(_onGetCancelReason);
    on<CancelBooking>(_onCancelBooking);
    on<GetJourneyDetails>(_onGetJourneyDetails);
    on<BookQuotationEvent>(_onGetQuotation);
  }

  Future<void> _onGetHistory(
      FetchHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    BookingModel result = await historyRepo.getHistory({
      "userProfileSno": event.userProfileSno,
      "status": event.status == 0
          ? '{"Processing","Accept","Request_Pending","Started","Pending"}'
          : '{"Completed","Cancel"}',
      "skip": event.skip,
      "limits": event.limits
    });
    print("jsonEncode${jsonEncode(result)}");
    if (result.isSuccess ?? false) {
      emit(HistoryLoaded(BookingList: result.json ?? []));
    } else {}
  }

  Future<void> _onGetQuotation(
      BookQuotationEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    print('event lng: ${event.lng}');

    SearchQuotationServiceProviderScheduleModel result =
        await historyRepo.getQuotationStatus({
      "service_booking_sno": event.serviceBookingSno,
      "lat": event.lat,
      "lng": event.lng,
      "bookingPerson": event.bookingPersonSno,
      "sub_category_sno": event.subCategorySno
    });

    print('Result JSON: ${jsonEncode(result)}');

    if (result.isSuccess) {
      if (result.json != null &&
          result.json!.isNotEmpty &&
          result.json!.first.searchQuotationServiceProviderSchedule != null &&
          result
              .json!.first.searchQuotationServiceProviderSchedule!.isNotEmpty &&
          result.json!.first.searchQuotationServiceProviderSchedule!.first
                  .serviceBookingSno !=
              null) {
      } else {
        var message = result
            .json?.first.searchQuotationServiceProviderSchedule?.first.message;
        print('Message to emit: $message');
        emit(Message(
            message: message ?? "New Quotation add Successfully", code: 0));
      }
    } else {
      emit(Message(message: "Please try again", code: 0));
    }
  }

  Future<void> _onGetCancelReason(
      FetchCancelReason event, Emitter<HistoryState> emit) async {
    CancelReasonModel result =
        await historyRepo.getCancelReason({"role": "Customer"});
    if (result.isSuccess) {
      emit(FetchCancelReasonState(cancelReasonList: result.json ?? []));
    }
  }

  Future<void> _onCancelBooking(
      CancelBooking event, Emitter<HistoryState> emit) async {
    print("cancelBooking ${event.cancelBooking.toJson()}");
    CancelBookingResultModel result =
        await historyRepo.cancelBooking(event.cancelBooking.toJson());
    if (result.isSuccess) {
      if (result.json!.isNotEmpty) {
        emit(CancelBookingState());
      }
    }
  }

  Future<void> _onGetJourneyDetails(
      GetJourneyDetails event, Emitter<HistoryState> emit) async {
    print(event.service_booking_sno);
    JourneyDetailsModel result = await historyRepo
        .getTrackOrder({"service_booking_sno": event.service_booking_sno});
    print('result${jsonEncode(result)}');
    if (result.isSuccess) {
      if (result.json!.isNotEmpty) {
        emit(GetJourneyDetailsState(journeyDetails: result.json!.first));
      }
    }
  }

  // Future<void> _onGetHistory(HistoryEvent event) async {

  //     // Fetch new data
  //     emit(HistoryLoading());

  //     try {
  //       // Simulate data fetching
  //       await Future.delayed(const Duration(seconds: 2));
  //       final newItems = List.generate(
  //         _pageSize,
  //         (index) => 'Item ${_currentPage * _pageSize + index}',
  //       );
  //       final hasReachedMax = newItems.length < _pageSize;
  //       _currentPage++;
  //       final currentItems = (state is HistoryLoaded
  //               ? (state as HistoryLoaded).historyItems
  //               : []) +
  //           newItems;
  //       emit(HistoryLoaded(currentItems, hasReachedMax: hasReachedMax));
  //     } catch (_) {
  //       emit(HistoryError('Failed to fetch history'));
  //     }
  // }
}

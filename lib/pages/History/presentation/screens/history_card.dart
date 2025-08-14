import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/History/bloc/history_bloc.dart';
import 'package:truklynk/pages/History/bloc/history_event.dart';
import 'package:truklynk/pages/History/bloc/history_state.dart';
import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/presentation/constants/history_theme.dart';
import 'package:truklynk/pages/History/presentation/screens/history_card_body.dart';
import 'package:truklynk/pages/History/presentation/screens/history_card_header.dart';
import 'package:truklynk/services/token_service.dart';

// ignore: must_be_immutable
class HistoryCard extends StatefulWidget {
  int status;
  HistoryCard({super.key, required this.status});

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  HistoryBloc historyBloc = HistoryBloc();
  final ScrollController _scrollController = ScrollController();
  List<Booking> BookingList = [];
  TokenService tokenService = TokenService();

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<Createuser?> getUser() async {
    Createuser? user = await tokenService.getUser();
    historyBloc.add(FetchHistory(
        userProfileSno: user!.userProfileSno!,
        status: widget.status,
        skip: 0,
        limits: 10));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => historyBloc,
        child:
            BlocConsumer<HistoryBloc, HistoryState>(listener: (context, state) {
          if (state is HistoryLoaded) {
            BookingList = state.BookingList;
            print("BookingList${jsonEncode(BookingList)}");
          }
        }, builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (BookingList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🧳',
                      style:
                          TextStyle(fontSize: 100), // Large emoji for emphasis
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Trips Found',
                      style: TextStyle(
                        color: HistoryTheme.whiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '🤔 Looks like you have no trips scheduled at this moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ]),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: BookingList.length,
                itemBuilder: (context, index) {
                  Booking booking = BookingList[index];
                  return Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        HistoryCardHeader(
                            orderNo: '${booking.serviceBookingSno}',
                            bookingStatus: '${booking.bookingStatusName}'),
                        HistoryCardBody(
                          booking: booking,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        }));
  }
}

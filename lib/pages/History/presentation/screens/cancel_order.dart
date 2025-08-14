import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/History/bloc/history_event.dart';
import 'package:truklynk/pages/History/data/models/booking_cancel_reason_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_reason_model.dart';
import 'package:truklynk/services/token_service.dart';

import '../../../Auth/presentation/constants/auth_theme.dart';
import '../../../Order/presentation/constants/order_theme.dart';
import '../../bloc/history_bloc.dart';
import '../../bloc/history_state.dart';
import '../constants/history_theme.dart';

class CancelOrder extends StatefulWidget {
  int serviceBookingSno;
  CancelOrder({super.key, required this.serviceBookingSno});

  @override
  State<CancelOrder> createState() => _CancelOrderState();
}

class _CancelOrderState extends State<CancelOrder> {
  HistoryBloc historyBloc = HistoryBloc();
  int _selectedValue = 0;
  List<CancelReason> cancelReasonList = [];
  TextEditingController otherReasonController = TextEditingController();
  TokenService tokenService = TokenService();
  Createuser? user;

  @override
  void initState() {
    print("serviceBookingSno ${widget.serviceBookingSno}");
    historyBloc.add(FetchCancelReason());
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    user = await tokenService.getUser();
  }

  @override
  void dispose() {
    otherReasonController.dispose(); // Dispose of the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => historyBloc,
        child:
            BlocConsumer<HistoryBloc, HistoryState>(listener: (context, state) {
          if (state is FetchCancelReasonState) {
            cancelReasonList = state.cancelReasonList;
          }
          if (state is CancelBookingState) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/BottomBar', (Route route) => false);
          }
        }, builder: (context, state) {
          return SafeArea(
              child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              surfaceTintColor: Colors.black,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close), // iOS-style back icon
                onPressed: () {
                  Navigator.pop(context); // Pop the current route
                },
              ),
              title: const Text(
                'Cancel Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(23),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your order is very important to the driver',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                              Text(
                                'Please share your reason to help improve order service quality',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 10.0),
                          child: Card(
                            elevation: 5,
                            color: HistoryTheme.primaryColor.withOpacity(0.4),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...cancelReasonList
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    CancelReason reason = entry.value;

                                    return RadioListTile(
                                      activeColor: HistoryTheme.secondaryColor,
                                      value: index,
                                      groupValue: _selectedValue,
                                      title: Text(
                                        reason.reason ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onChanged: (int? value) {
                                        setState(() {
                                          _selectedValue = value!;
                                        });
                                      },
                                    );
                                  }),
                                  Visibility(
                                    visible: _selectedValue ==
                                        cancelReasonList.indexWhere(
                                            (r) => r.reason == 'Other'),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: TextField(
                                        controller: otherReasonController,
                                        maxLength: 255,
                                        maxLines: 3,
                                        keyboardType: TextInputType.text,
                                        style: const TextStyle(
                                            color: AuthTheme.whiteColor),
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your reason',
                                          counterText: '',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          CancelBookingModel cancelBooking =
                              CancelBookingModel();
                          cancelBooking.bookingStatusName = "Cancel";
                          cancelBooking.serviceBookingSno =
                              widget.serviceBookingSno;
                          cancelBooking.userProfileSno = user!.userProfileSno;
                          cancelBooking.updatedTime = DateTime.now();
                          cancelBooking.isSendNotification = true;
                          cancelBooking.cancelreasonSno =
                              cancelReasonList[_selectedValue].cancelReasonSno;
                          cancelBooking.isCustomer = false;
                          cancelBooking.cancelreason =
                              cancelReasonList[_selectedValue].reason == 'Other'
                                  ? otherReasonController.text
                                  : cancelReasonList[_selectedValue].reason;
                          historyBloc
                              .add(CancelBooking(cancelBooking: cancelBooking));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderTheme.whiteColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Confirm',
                            style: TextStyle(
                                color: OrderTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
              ],
            ),
          ));
        }));
  }
}

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/widgets/alert_dialog.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/History/data/models/booking_cancel_reason_model.dart';
import 'package:truklynk/pages/Order/bloc/order_event.dart';
import 'package:truklynk/pages/Order/data/models/booking_status_model.dart';
import 'package:truklynk/pages/Order/presentation/screens/dotted_line.dart';
import 'package:truklynk/services/token_service.dart';
import 'package:truklynk/utils/helper_functions.dart';

import '../../bloc/order_bloc.dart';
import '../../bloc/order_state.dart';
import '../constants/order_theme.dart';

class ConfirmBooking extends StatefulWidget {
  ServiceProviderList booking;
  ConfirmBooking({super.key, required this.booking});

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  OrderBloc orderBloc = OrderBloc();
  TokenService tokenService = TokenService();
  late Createuser? user;

  @override
  void initState() {
    print(widget.booking.toJson());
    _getUserDetails();
    print('widget${jsonEncode(widget.booking)}');
    super.initState();
  }

  Future<void> _getUserDetails() async {
    user = await tokenService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => orderBloc,
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/BottomBar', (Route route) => false);
            }
            if (state is RejectSuccess) {
              widget.booking.quotationStatusCode = 0;
            }
            if (state is BlockServiceProviderState) {
              widget.booking.quotationStatusCode = 0;
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  surfaceTintColor: Colors.black,
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios), // iOS-style back icon
                    onPressed: () {
                      Navigator.pop(context); // Pop the current route
                    },
                  ),
                  title: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: OrderTheme.blackColor,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Card(
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        // padding: const EdgeInsets.all(8),
                                        child: ListTile(
                                          leading: ClipOval(
                                            child: Image.asset(
                                              'assets/images/profile2.png', // Replace with your image path
                                              height: 51,
                                              width: 51,
                                            ),
                                          ),
                                          title: Text(
                                              '${widget.booking.serviceProviderName}',
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(
                                            '${widget.booking.city}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 6.0, bottom: 12.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: Colors.white.withOpacity(
                                                    0.3)), // Add this line
                                          ),
                                          width: 300,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 22,
                                                      vertical: 10),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/deliveryvan.png',
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        '${widget.booking.bookingDetails!.vehicleName}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 18,
                                                      vertical: 2),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/archive.png',
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        '${widget.booking.ratings!.totalOrders} orders',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.3)), // Add this line
                                                        ),
                                                        height: 28,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Row(
                                                            children: [
                                                              for (int i = 0;
                                                                  i < 5;
                                                                  i++)
                                                                Icon(Icons.star,
                                                                    size: 14,
                                                                    color: i <
                                                                            (widget.booking.ratings!.overallRating ??
                                                                                0)
                                                                        ? Colors
                                                                            .yellow
                                                                        : Colors
                                                                            .white),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        '${widget.booking.ratings!.totalOrders} Ratings',
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 8,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 12),
                                          child: Text(
                                            'Address of Order',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Image(
                                              image: AssetImage(
                                                  'assets/images/pick-drop.png'),
                                              height: 100,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(children: [
                                                Card(
                                                    color:
                                                        OrderTheme.primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${widget.booking.bookingDetails!.pickupLocation!.address}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                const SizedBox(height: 16),
                                                Card(
                                                    color:
                                                        OrderTheme.primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${widget.booking.bookingDetails!.dropLocation!.address}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                              ]),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 10.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 1.0, // Change this line
                                            color: Colors.grey.withOpacity(0.1),
                                            child: CustomPaint(
                                              painter: DottedLine(),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Image(
                                            image: AssetImage(
                                                'assets/images/phone.png'),
                                            height: 17,
                                            width: 17,
                                          ),
                                          title: Stack(
                                            children: [
                                              // Blurred text
                                              ImageFiltered(
                                                imageFilter:
                                                    ui.ImageFilter.blur(
                                                  sigmaX: widget.booking
                                                                  .driverName !=
                                                              null &&
                                                          widget.booking
                                                                  .price !=
                                                              null &&
                                                          widget.booking.price >
                                                              0
                                                      ? 0
                                                      : 5.0,
                                                  sigmaY: widget.booking
                                                                  .driverName !=
                                                              null &&
                                                          widget.booking
                                                                  .price !=
                                                              null &&
                                                          widget.booking.price >
                                                              0
                                                      ? 0
                                                      : 5.0,
                                                ),
                                                child: Text(
                                                  '${widget.booking.driverName ?? 'waiting quotation'}, ${widget.booking.mobileNo ?? '+91 12*******'}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              // Overlay text for clarity
                                              if (widget.booking.driverName ==
                                                  null)
                                                const Center(
                                                  child: Text(
                                                    'waiting quotation',
                                                    style: TextStyle(
                                                      color: OrderTheme
                                                          .secondaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      backgroundColor: Colors
                                                          .black54, // Optional background for readability
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 10.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 1.0, // Change this line
                                            color: Colors.grey.withOpacity(0.1),
                                            child: CustomPaint(
                                              painter: DottedLine(),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Image(
                                            image: AssetImage(
                                                'assets/images/time.png'),
                                            height: 16,
                                            width: 16,
                                          ),
                                          title: Text(
                                            '${bookingDateTimeFormat(widget.booking.bookingDetails!.bookingTime ?? DateTime.now())}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (widget.booking.bookingDetails!
                                            .notes!.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 10.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: 1.0, // Change this line
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              child: CustomPaint(
                                                painter: DottedLine(),
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            leading: const Image(
                                              image: AssetImage(
                                                  'assets/images/message.png'),
                                              height: 16,
                                              width: 16,
                                            ),
                                            title: Text(
                                              '${widget.booking.bookingDetails!.notes}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Card(
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              // Wrap the Column with Expanded
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Total cost',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    '(Incl. taxes, charges & platform fee)',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            InkWell(
                                              onTap: () {
                                                _showBottomSheet(context);
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${widget.booking.price != null ? 'Rs. ' : ''} ${widget.booking.price ?? ' Waiting'}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // if (widget.booking.quotationStatusCode.toString() == '1' &&
                    //     widget.booking.driverName != null &&
                    //     widget.booking.price != null &&
                    //     widget.booking.price > 0)
                    _buildConformButton(context)
                    // _buildContinueButton(context),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildConformButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: OrderTheme.blackColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                showCustomAlertDialog(
                  dialogBackgroundColor: OrderTheme.whiteColor,
                  title: 'Notice',
                  titleColor: OrderTheme.blackColor,
                  context: context,
                  contentColor: OrderTheme.textGrey,
                  content: "In the future, skip this pilot ?",
                  cancelText: 'No',
                  onConfirm: () {
                    orderBloc.add(BlockServiceProviderEvent(
                        service_provider_quotation_sno:
                            widget.booking.serviceProviderQuotationSno,
                        service_provider_sno:
                            widget.booking.serviceProviderSno ?? 0,
                        users_sno: user!.usersSno ?? 0,
                        created_on: DateTime.now().toString()));
                  },
                  onCancel: () {
                    orderBloc.add(RejectServiceProviderEvent(
                        service_provider_quotation_sno:
                            widget.booking.serviceProviderQuotationSno,
                        quotation_status_name: 'Customer_Reject',
                        driver_user_profile_sno:
                            widget.booking.userProfileSno));
                  },
                  confirmButtonColor: OrderTheme.secondaryColor,
                  cancelButtonColor: OrderTheme.blackColor,
                  confirmText: "Yes",
                );
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: OrderTheme.whiteColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Debug print to check nearbyVehicles state
                print('nearbyVehicles: ${widget.booking.nearbyVehicles}');

                // Safely determine vehicle_sno
                final vehicleSno = (widget.booking.nearbyVehicles != null &&
                        widget.booking.nearbyVehicles!.isNotEmpty)
                    ? widget.booking.nearbyVehicles!.first.vehicleSno
                    : null;

                orderBloc.add(QuoteConfirmationEvent(
                  service_booking_sno:
                      widget.booking.bookingDetails?.service_booking_sno,
                  service_provider_sno: widget.booking.serviceProviderSno,
                  vehicle_sno: vehicleSno,
                  user_profile_sno: widget.booking.userProfileSno,
                  driver_user_profile_sno: widget.booking.driverSno,
                  price: widget.booking.price,
                  updated_on: DateTime.now().toString(),
                  registering_type: "Individual",
                ));
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: OrderTheme.secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Set to false
      backgroundColor: OrderTheme.cardBackground,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *
              0.4, // Set the height of the bottom sheet
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      'Bill Summary',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Card(
                  elevation: 5,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       vertical: 8.0, horizontal: 10.0),
                          //   child: Container(
                          //     width: double.infinity,
                          //     height: 1.0, // Change this line
                          //     color: Colors.grey.withOpacity(0.4),
                          //     child: CustomPaint(
                          //       painter: DottedLine(),
                          //     ),
                          //   ),
                          // ),
                          ListTile(
                            leading: const Image(
                              image: AssetImage('assets/images/truk.png'),
                              height: 16,
                              width: 16,
                            ),
                            title: const Text(
                              'Shipping Cost',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: Text(
                              'Rs.${widget.booking.price ?? '0'}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 1.0, // Change this line
                              color: Colors.grey.withOpacity(0.1),
                              child: CustomPaint(
                                painter: DottedLine(),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Image(
                              image: AssetImage('assets/images/bank.png'),
                              height: 16,
                              width: 16,
                            ),
                            title: const Text(
                              'GST and Taxes (5%)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: Text(
                              'Rs.${widget.booking.priceBreakup?['gst'] ?? '0'}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 1.0, // Change this line
                              color: Colors.grey.withOpacity(0.1),
                              child: CustomPaint(
                                painter: DottedLine(),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Image(
                              image: AssetImage('assets/images/time.png'),
                              height: 16,
                              width: 16,
                            ),
                            title: const Text(
                              'Total Cost',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            trailing: Text(
                              'Rs.${widget.booking.price ?? '0'}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

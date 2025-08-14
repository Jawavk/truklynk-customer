import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/models/header_model.dart';
import 'package:truklynk/common/widgets/card.dart';
import 'package:truklynk/common/widgets/custom_list_tile.dart';
import 'package:truklynk/common/widgets/listtile.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/History/bloc/history_state.dart';
import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/presentation/constants/history_theme.dart';
import 'package:truklynk/utils/helper_functions.dart';
import '../../../../common/widgets/dashed_divider.dart';
import '../../bloc/history_bloc.dart';
import '../../bloc/history_event.dart';

// ignore: must_be_immutable
class HistoryCardBody extends StatefulWidget {
  Booking booking;
  HistoryCardBody({super.key, required this.booking});

  @override
  State<HistoryCardBody> createState() => _HistoryCardBodyState();
}

class _HistoryCardBodyState extends State<HistoryCardBody> {
  HistoryBloc historyBloc = HistoryBloc();

  @override
  void initState() {
    // Debug booking data to identify nulls
    print('Booking: ${widget.booking.toString()}');
    print('bookingStatusName: ${widget.booking.bookingStatusName}');
    print('serviceBookingSno: ${widget.booking.serviceBookingSno}');
    print('pickupLocation.city: ${widget.booking.pickupLocation?.city}');
    super.initState();
  }

  void retryBooking(int serviceBookingSno) {
    print("Making API call with serviceBookingSno: $serviceBookingSno");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => historyBloc,
      child: BlocConsumer<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state is Message) {
            toast(message: state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 15),
                CustomListTile(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  backgroundColor: HistoryTheme.cardBackgroundColor,
                  leading: HeaderItem(
                    isExpanded: true,
                    widget: Text(
                      widget.booking.pickupLocation?.city?.isNotEmpty == true
                          ? widget.booking.pickupLocation!.city!
                          : widget.booking.pickupLocation?.address
                                  ?.split(',')[0] ??
                              'Unknown',
                      style: const TextStyle(
                        color: AppTheme.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  title: HeaderItem(
                    isExpanded: true,
                    color: AppTheme.whiteColor,
                    isCenter: true,
                    widget: const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.whiteColor,
                    ),
                  ),
                  trailing: HeaderItem(
                    isExpanded: true,
                    widget: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.booking.dropLocation?.city?.isNotEmpty == true
                            ? widget.booking.dropLocation!.city!
                            : widget.booking.dropLocation?.address
                                    ?.split(',')[0] ??
                                'Unknown',
                        style: const TextStyle(
                          color: AppTheme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/calendar.png',
                              width: 40, height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              localDateTimeFormat(
                                  widget.booking.bookingTime ?? DateTime.now()),
                              style: const TextStyle(
                                color: AppTheme.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/goods.png',
                              width: 40, height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.booking.typesOfGoods ?? 'Unknown Goods',
                              style: const TextStyle(
                                color: AppTheme.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/transport.png',
                              width: 40, height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.booking.subcategoryName ??
                                  'Unknown Vehicle',
                              style: const TextStyle(
                                color: AppTheme.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/kg.png',
                              width: 40, height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${widget.booking.weightOfGoods ?? 'N/A'} ${widget.booking.weightTypeName ?? ''}',
                              style: const TextStyle(
                                color: AppTheme.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DashedDivider(
                  dashWidth: 10.0,
                  dashHeight: 2.0,
                  space: 4.0,
                  color: HistoryTheme.ashColor.withOpacity(0.2),
                ),
                if ((widget.booking.bookingStatusName?.toLowerCase() ?? '') !=
                        'processing' &&
                    (widget.booking.price ?? 0) > 0) ...[
                  const SizedBox(height: 10),
                  CustomListTile(
                    leading: HeaderItem(
                      isExpanded: true,
                      widget: const Text(
                        "Trip price",
                        style: TextStyle(
                          color: HistoryTheme.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    trailing: HeaderItem(
                      isExpanded: true,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Rs. ${widget.booking.price?.toString() ?? 'N/A'}",
                            style: const TextStyle(
                              color: AppTheme.whiteColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppTheme.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DashedDivider(
                    dashWidth: 10.0,
                    dashHeight: 2.0,
                    space: 4.0,
                    color: HistoryTheme.ashColor.withOpacity(0.2),
                  ),
                ],
                const SizedBox(height: 10),
                if (widget.booking.bookingStatusName?.toLowerCase() !=
                    'cancel') ...[
                  if (widget.booking.bookingStatusName?.toLowerCase() ==
                          'processing' ||
                      widget.booking.bookingStatusName ==
                          'Request_Pending') ...[
                    InkWell(
                      onTap: () {
                        if (widget.booking.serviceBookingSno != null &&
                            widget.booking.createdOn != null) {
                          Navigator.pushNamed(
                            context,
                            '/SearchProviderScreen',
                            arguments: {
                              'serviceBookingId':
                                  widget.booking.serviceBookingSno,
                              'createdOn': DateTime.parse(
                                  widget.booking.createdOn.toString()),
                            },
                          );
                        }
                      },
                      child: CustomListTile(
                        leading: HeaderItem(
                          isExpanded: true,
                          widget: const Text(
                            "View Quotation",
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        trailing: HeaderItem(
                          isExpanded: true,
                          widget: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.booking.bookingStatusName ==
                        'Request_Pending') ...[
                      const SizedBox(height: 10),
                      DashedDivider(
                        dashWidth: 10.0,
                        dashHeight: 2.0,
                        space: 4.0,
                        color: HistoryTheme.ashColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your request has been accepted and our customer support team will be in touch with you shortly!',
                        style: TextStyle(color: HistoryTheme.secondaryColor),
                      ),
                      const SizedBox(height: 10),
                      DashedDivider(
                        dashWidth: 10.0,
                        dashHeight: 2.0,
                        space: 4.0,
                        color: HistoryTheme.ashColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showPopupDialog(context);
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: HistoryTheme.whiteColor,
                              size: 18,
                            ),
                            label: const Text(
                              'Retry',
                              style: TextStyle(
                                color: HistoryTheme.whiteColor,
                                fontSize: 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: HistoryTheme.secondaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    if (widget.booking.bookingStatusCd != 78 &&
                        widget.booking.bookingStatusCd != 106) ...[
                      InkWell(
                        onTap: () {
                          if (widget.booking.serviceBookingSno != null) {
                            Navigator.pushNamed(context, '/TrackTrip',
                                arguments: {
                                  "serviceBookingSno": widget.booking,
                                });
                          }
                        },
                        child: CustomListTile(
                          leading: HeaderItem(
                            isExpanded: true,
                            widget: const Text(
                              "Track Order",
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          trailing: HeaderItem(
                            isExpanded: true,
                            widget: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void showPopupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirm",
            style: TextStyle(fontSize: 18, color: AppTheme.whiteColor),
          ),
          content: const Text(
            "Retrying will remove previous quotations.",
            style: TextStyle(fontSize: 14, color: AppTheme.whiteColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.booking.serviceBookingSno != null &&
                    widget.booking.bookingPerson != null &&
                    widget.booking.subCategorySno != null) {
                  historyBloc.add(BookQuotationEvent(
                    serviceBookingSno: widget.booking.serviceBookingSno!,
                    lat: widget.booking.pickupLocation?.latlng?.latitude ?? 0.0,
                    lng:
                        widget.booking.pickupLocation?.latlng?.longitude ?? 0.0,
                    bookingPersonSno: widget.booking.bookingPerson!,
                    subCategorySno: widget.booking.subCategorySno!,
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "OK",
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

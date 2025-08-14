import 'package:flutter/material.dart';
import 'package:truklynk/common/models/header_model.dart';
import 'package:truklynk/common/widgets/custom_list_tile.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/History/presentation/constants/history_theme.dart';
import 'package:truklynk/utils/helper_functions.dart';

// ignore: must_be_immutable
class HistoryCardHeader extends StatefulWidget {
  String orderNo;
  String bookingStatus;
  HistoryCardHeader(
      {super.key, required this.orderNo, required this.bookingStatus});

  @override
  State<HistoryCardHeader> createState() => _HistoryCardHeaderState();
}

class _HistoryCardHeaderState extends State<HistoryCardHeader> {
  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      backgroundColor: Colors.transparent,
      leading: HeaderItem(
        isExpanded: true,
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        isCenter: false,
        widget: Text('Order No. #${widget.orderNo}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1),
        onTap: () {},
      ),
      title: null,
      trailing: HeaderItem(
          isExpanded: true,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
          backgroundColor: HistoryTheme.blueColor,
          color: AppTheme.whiteColor,
          isCenter: true,
          padding: const EdgeInsets.all(15),
          widget: Text(formatString(widget.bookingStatus),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1),
          onTap: () {}),
    );
  }
}

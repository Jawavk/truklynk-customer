import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truklynk/config/theme.dart'; // Added for better context and modal usage

class CustomCupertinoDatePicker extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime selctedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final ValueChanged<DateTime> onConfirm;
  final VoidCallback onCancel;
  final CupertinoDatePickerMode mode;

  const CustomCupertinoDatePicker({
    super.key,
    required this.initialDateTime,
    required this.selctedDateTime,
    required this.onDateTimeChanged,
    required this.onConfirm,
    required this.onCancel,
    this.mode = CupertinoDatePickerMode.dateAndTime,
  });

  @override
  _CustomCupertinoDatePickerState createState() =>
      _CustomCupertinoDatePickerState();
}

class _CustomCupertinoDatePickerState extends State<CustomCupertinoDatePicker> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  void _handleDateTimeChanged(DateTime dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
    });
    widget.onDateTimeChanged(dateTime); // Still notify parent
  }

  void _handleConfirm() {
    widget.onConfirm(_selectedDateTime);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Adjusted height to fit buttons
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.whiteColor,
      ),
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.light),
                child: CupertinoDatePicker(
                  minimumDate: widget.initialDateTime,
                  use24hFormat: false,
                  mode: widget.mode,
                  initialDateTime: widget.selctedDateTime,
                  onDateTimeChanged: _handleDateTimeChanged,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onCancel;
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.secondaryColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme
                            .secondaryColor, // Set the background color here
                      ),
                      onPressed: _handleConfirm,
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: AppTheme.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24)
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  required DateTime selctedDateTime,
  required ValueChanged<DateTime> onDateTimeChanged,
  required ValueChanged<DateTime> onConfirm,
  required VoidCallback onCancel,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 300, // Adjust height to fit buttons
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: CustomCupertinoDatePicker(
            initialDateTime: initialDateTime,
            selctedDateTime: selctedDateTime,
            onDateTimeChanged: onDateTimeChanged,
            onConfirm: onConfirm,
            onCancel: onCancel,
            mode: mode,
          ),
        ),
      );
    },
  );
}

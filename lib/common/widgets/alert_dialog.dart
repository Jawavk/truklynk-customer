import 'package:flutter/material.dart';

// Define a reusable AlertDialog widget
class CustomAlertDialog extends StatelessWidget {
  final String? title; // Make title optional
  final String? content; // Make content optional
  final VoidCallback onConfirm; // Callback function for confirmation
  final String confirmText;
  final VoidCallback? onCancel; // Nullable callback function for cancellation
  final String cancelText;
  final TextAlign titleAlignment; // Title alignment (left, center, right)
  final int contentMaxLines; // Maximum lines for the content
  final Color? confirmButtonColor; // Color for the confirm button
  final Color? cancelButtonColor; // Color for the cancel button
  final Color? titleColor; // Color for the confirm button
  final Color? contentColor;
  final Color? dialogBackgroundColor;

  const CustomAlertDialog({
    super.key,
    this.title,
    this.content,
    required this.onConfirm,
    this.confirmText = 'OK',
    this.onCancel,
    this.cancelText = 'Cancel',
    this.titleAlignment = TextAlign.center,
    this.contentMaxLines = 2,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.titleColor,
    this.contentColor,
    this.dialogBackgroundColor,
  }) : assert(title != null || content != null, 'At least one of title or content must be provided');


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: dialogBackgroundColor ?? Theme.of(context).dialogBackgroundColor,
      title: title != null
          ? Text(
              title!,
              textAlign: titleAlignment,
        style: TextStyle(color: titleColor ?? Theme.of(context).dialogBackgroundColor,fontWeight: FontWeight.w700),
            )
          : null,
      content: content != null
          ? Text(
              content!,
              maxLines: contentMaxLines,
              overflow: TextOverflow.ellipsis,
        style: TextStyle(color: contentColor ?? Theme.of(context).dialogBackgroundColor),
            )
          : null,
      actions: <Widget>[
        if (onCancel != null)
          TextButton(
            child: Text(
              cancelText,
              style: TextStyle(
                color: cancelButtonColor ??
                    Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onCancel
                  ?.call(); // Safely call the cancel callback if it's provided
            },
          ),
        TextButton(
          child: Text(
            confirmText,
            style: TextStyle(
              color:
                  confirmButtonColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(); // Call the confirm callback
          },
        ),
      ],
    );
  }
}

Future<bool?> showCustomAlertDialog({
  required BuildContext context,
  String? title,
  String? content,
  required VoidCallback onConfirm,
  String confirmText = 'OK',
  VoidCallback? onCancel,
  String cancelText = 'Cancel',
  TextAlign titleAlignment = TextAlign.center,
  int contentMaxLines = 2,
  Color? confirmButtonColor,
  Color? cancelButtonColor,
  Color? titleColor,
  Color? contentColor,
  Color? dialogBackgroundColor
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        onCancel: onCancel,
        cancelText: cancelText,
        titleAlignment: titleAlignment,
        contentMaxLines: contentMaxLines,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        titleColor:titleColor,
        contentColor:contentColor,
        dialogBackgroundColor:dialogBackgroundColor
      );
    },
  );
}

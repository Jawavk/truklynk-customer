import 'package:flutter/material.dart';

class CustomSuccessAlertDialog extends StatelessWidget {
  final String? title; // Make title optional
  final String? content; // Make content optional
  final VoidCallback onConfirm; // Callback function for confirmation
  final String? confirmText;
  final TextAlign titleAlignment; // Title alignment (left, center, right)
  final int contentMaxLines; // Maximum lines for the content
  final Color? confirmButtonColor;
  final Color? confirmButtonTextColor;
  final Color? titleColor; // Color for the confirm button
  final Color? contentColor;
  final Color? dialogBackgroundColor;
  final Widget? header;

  const CustomSuccessAlertDialog(
      {super.key,
      this.title,
      this.content,
      required this.onConfirm,
      this.confirmText,
      this.titleAlignment = TextAlign.center,
      this.contentMaxLines = 2,
      this.confirmButtonColor,
      this.confirmButtonTextColor,
      this.titleColor,
      this.contentColor,
      this.dialogBackgroundColor,
      this.header})
      : assert(title != null || content != null,
            'At least one of title or content must be provided');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          dialogBackgroundColor ?? Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      titlePadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add an image or GIF at the top
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: header!,
            ),
          const SizedBox(height: 10),
          // Title of the dialog
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                title!,
                textAlign: titleAlignment ?? TextAlign.center,
                style: TextStyle(
                  color: titleColor ?? Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20, // Adjust font size for title
                ),
              ),
            )
          else
            Container(),
          const SizedBox(height: 5),
          if (content != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                content!,
                maxLines: contentMaxLines ?? 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // Align subtitle in the center
                style: TextStyle(
                  color: contentColor ??
                      Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16, // Adjust font size for content
                ),
              ),
            )
          else
            Container()
        ],
      ),
      actions: <Widget>[
        // Confirm button
        Container(
          margin: EdgeInsets.only(top: 20),
          width: MediaQuery.sizeOf(context).width,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: confirmButtonColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              confirmText!,
              style: TextStyle(
                color: confirmButtonTextColor ??
                    Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool?> showCustomSuccessAlertDialog({
  required BuildContext context,
  String? title,
  String? content,
  required VoidCallback onConfirm,
  String? confirmText = "Confirm",
  TextAlign titleAlignment = TextAlign.center,
  int contentMaxLines = 2,
  Color? confirmButtonColor,
  Color? confirmButtonTextColor,
  Color? titleColor,
  Color? contentColor,
  Color? dialogBackgroundColor,
  Widget? header,
  bool barrierDismissible = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return CustomSuccessAlertDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        titleAlignment: titleAlignment,
        contentMaxLines: contentMaxLines,
        confirmButtonColor: confirmButtonColor,
        confirmButtonTextColor: confirmButtonTextColor,
        titleColor: titleColor,
        contentColor: contentColor,
        dialogBackgroundColor: dialogBackgroundColor,
        header: header,
      );
    },
  );
}

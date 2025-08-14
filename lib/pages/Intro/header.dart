import 'package:flutter/material.dart';
import 'package:truklynk/config/theme.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const HeaderWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor, // Black background for the header
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left logo
          Image.asset(
            'assets/images/logo.png',
            width: 104, // Adjust width as needed
            height: 27, // Adjust height as needed
          ),

          // Title in the middle (optional, you can remove it if not needed)

          // Right skip button
          DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
            )),
            child: TextButton(
              onPressed: onPressed,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

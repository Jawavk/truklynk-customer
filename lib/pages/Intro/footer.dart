import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onNextPressed;
  final bool
      showBackButton; // New parameter to control the visibility of the back button

  const FooterWidget({
    super.key,
    required this.onBackPressed,
    required this.onNextPressed,
    this.showBackButton = true, // Default value is true
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showBackButton) // Conditionally include the back button
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF3A3A3C), // Gray background color
                shape: const CircleBorder(), // Circular shape
                padding:
                    const EdgeInsets.all(16), // Adjust padding for the icon
              ),
              child: const Icon(
                Icons.arrow_back, // Back icon
                color: Colors.white,
              ),
            ),
          Expanded(
              child:
                  Container()), // Spacer to push the "Next" button to the right
          TextButton(
            onPressed: onNextPressed,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white, // Background color of the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Adjust padding
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Ensure the row sizes to the minimum needed
                children: [
                  const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ), // Customize text style if needed
                  ),
                  const SizedBox(width: 8), // Spacing between text and icon
                  Image.asset(
                    'assets/images/right-arrow.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

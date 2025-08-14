import 'package:flutter/material.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/Auth/presentation/screens/login.dart';
import 'package:truklynk/pages/Intro/footer.dart';
import 'package:truklynk/pages/Intro/header.dart';
import 'package:truklynk/services/token_service.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  TokenService tokenService = TokenService();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0; // Track the current page index

  void _scrollTo(int index) {
    if (index < 0 || index >= 3) return; // Ensure index is within bounds
    _scrollController
        .animateTo(
      index * MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      setState(() {
        _currentIndex = index;
      });
    });
  }

  void _handleBack() {
    if (_currentIndex > 0) {
      _scrollTo(_currentIndex - 1); // Scroll to previous item
    }
  }

  void _handleNext() async {
    if (_currentIndex < 2) {
      // Assuming there are 3 screens (0, 1, 2)
      _scrollTo(_currentIndex + 1); // Scroll to next item
    } else {
      skip();
    }
  }

  skip() async {
    await tokenService.saveIntro("true");
    goToLogin();
  }

  Future<void> goToLogin() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ListView(
            physics: const NeverScrollableScrollPhysics(), // Disables scrolling
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _buildItem(
                  'assets/images/truck.png',
                  'Safe and Secure',
                  "Your cargo's safety is our top priority, from pick-up to drop-off.",
                  0),
              _buildItem(
                  'assets/images/delivery.png',
                  'On Time, Every Time',
                  'Trust us to deliver your goods swiftly and reliably, no matter the distance.',
                  1),
              _buildItem(
                  'assets/images/live_track.png',
                  'Efficient Deliveries',
                  'Streamline your logistics with real-time tracking and reliable service.',
                  2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      String image, String header, String description, int index) {
    return Container(
      color: AppTheme.primaryColor,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          HeaderWidget(onPressed: skip), // Use the text or customize as needed
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 58, right: 58),
                  child: Image.asset(
                    image,
                    width: 243,
                    height: 182,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Text(
                      header,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Text(
                      description,
                      textAlign: TextAlign
                          .center, // Center the text within the container
                      style: const TextStyle(
                          color: Colors.grey, // Change color based on isActive
                          fontSize: 12,
                          decoration: TextDecoration.none),
                      maxLines: 2, // Limit the text to 2 lines
                      overflow: TextOverflow
                          .ellipsis, // Handle overflow with ellipsis
                    ),
                  ),
                ),
                const SizedBox(
                  height: 69,
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentIndex == index ? 36 : 16,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentIndex == index ? Colors.red : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          FooterWidget(
            onBackPressed: _handleBack,
            onNextPressed: _handleNext,
            showBackButton: index > 0,
          ),
          const SizedBox(
            height: 46,
          ),
        ],
      ),
    );
  }
}

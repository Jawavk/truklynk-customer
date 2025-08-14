import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truklynk/common/widgets/permission_handler.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/services/token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TokenService tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    // await tokenService.clearIntro();
    // await tokenService.clearUser();
    Createuser? user = await tokenService.getUser();
    if (user != null && user.mobileNumber != null) {
      Timer(const Duration(seconds: 3), goToBottomBar);
    } else {
      Timer(const Duration(seconds: 3), _loadIntro);
    }
  }

  Future<void> _loadIntro() async {
    String? intro = await tokenService.getIntro();
    if (intro != null) {
      if (intro == 'true') {
        goToLogin();
      } else {
        goToIntro();
      }
    } else {
      goToIntro();
    }
  }

  void goToIntro() {
    Navigator.pushReplacementNamed(context, '/IntroScreen');
  }

  void goToLogin() {
    Navigator.pushReplacementNamed(context, '/LoginScreen');
  }

  void goToBottomBar() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/BottomBar', (Route route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppTheme.primaryColor,
        ),
        Positioned(
          right: 0,
          top: 108,
          bottom: 95,
          child: Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover, // Adjust the fit according to your needs
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 36,
          right: 36,
          height: MediaQuery.of(context).size.height,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0), // Adjust padding as needed
            child: Image.asset(
              'assets/images/logo.png',
              // width: 400, // Adjust size as needed
              // height: 400, // Adjust size as needed
            ),
          ),
        ),
      ],
    );
  }
}

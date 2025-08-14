import 'package:flutter/material.dart';
import 'package:truklynk/pages/Auth/presentation/screens/login.dart';
import 'package:truklynk/pages/Auth/presentation/screens/register.dart';
import 'package:truklynk/pages/BottomBar/presentation/screens/bottombar.dart';
import 'package:truklynk/pages/History/presentation/screens/cancel_order.dart';
import 'package:truklynk/pages/History/presentation/screens/history.dart';
import 'package:truklynk/pages/History/presentation/screens/track_trip.dart';
import 'package:truklynk/pages/Home/presentation/screens/home.dart';
import 'package:truklynk/pages/Intro/intro_screen.dart';
import 'package:truklynk/pages/Order/presentation/screens/confirm_booking.dart';
import 'package:truklynk/pages/Order/presentation/screens/order.dart';
import 'package:truklynk/pages/Order/presentation/screens/order_info.dart';
import 'package:truklynk/pages/Order/presentation/screens/pickup.dart';
import 'package:truklynk/pages/Order/presentation/screens/search_provider.dart';
import 'package:truklynk/pages/Profile/presentation/screens/blocked_service_providers.dart';
import 'package:truklynk/pages/SplashScreen/splash_screen.dart';

import '../pages/Order/presentation/screens/service_unavailable_screen.dart';

// Define your routes in a separate file
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/IntroScreen':
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
        );
      case '/LoginScreen':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case '/RegisterScreen':
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(phoneNumber: args),
        );
      case '/BottomBar':
        return MaterialPageRoute(
          builder: (_) => const BottomBar(),
        );
      case '/HomeScreen':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case '/HistoryScreen':
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
        );
      case '/OrderScreen':
        return MaterialPageRoute(
          builder: (_) => const OrderScreen(),
        );
      case '/OrderInfoScreen':
        return MaterialPageRoute(
          builder: (_) => const OrderInfoScreen(),
        );
      case '/Pickup':
        return MaterialPageRoute(
          builder: (_) => const Pickup(),
        );
      case '/ServiceUnavailableScreen':
        return MaterialPageRoute(
          builder: (_) => const ServiceUnavailableScreen(),
        );
      case '/SearchProviderScreen':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SearchProviderScreen(
              serviceBookingId: args?['serviceBookingId'] as int,
              createdOn: args?['createdOn'] as DateTime),
        );
      case '/ConfirmBooking':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ConfirmBooking(
            booking: args?['booking'],
          ),
        );
      case '/TrackTrip':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TrackTrip(booking: args?['serviceBookingSno']),
        );
      case '/CancelOrder':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              CancelOrder(serviceBookingSno: args?['serviceBookingSno']),
        );
      case '/BlockedSeviceProviders':
        return MaterialPageRoute(
          builder: (_) => const BlockedSeviceProviders(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }

  // Redirect to login screen
  MaterialPageRoute _redirectToLogin() {
    return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}

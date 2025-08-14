import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import 'dart:io';

import '../config/theme.dart';
import 'helper_model.dart';

final Logger logger = Logger();

Future<String> getDeviceId() async {
  String deviceId = '1234567890'; // Default fallback

  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // This is the Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '1234567890';
    } else {
      // For other platforms (web, desktop, etc.)
      deviceId = '1234567890';
    }
  } on PlatformException catch (e) {
    logger.e('Failed to get device ID: $e');
    deviceId = '1234567890';
  } catch (e) {
    logger.e('Unexpected error getting device ID: $e');
    deviceId = '1234567890';
  }

  return deviceId;
}

toast({required message, ToastGravity? position}) async {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: position ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppTheme.whiteColor,
      textColor: AppTheme.primaryColor,
      fontSize: 12.0);
}

Future<CustomePermission> checkGpsPermission() async {
  LocationPermission permission = await Geolocator.requestPermission();
  switch (permission) {
    case LocationPermission.always:
      return CustomePermission(
          status: true, message: 'Permission granted: Always');
    case LocationPermission.whileInUse:
      return CustomePermission(
          status: true, message: 'Permission granted: While in use');
    case LocationPermission.denied:
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return CustomePermission(status: false, message: 'Permission denied');
      }
      return CustomePermission(status: false, message: 'Permission denied');
    case LocationPermission.deniedForever:
      return CustomePermission(
          status: false, message: 'Permission denied forever');
    case LocationPermission.unableToDetermine:
      return CustomePermission(
          status: false, message: 'Unable to determine permission status');
  }
}

void printLongText(String text) {
  final pattern = RegExp('.{1,1000}'); // split every 1000 characters
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Future<Position> getCurrentPosition(
    {required LocationAccuracy accuracy}) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: accuracy),
    );
    return position;
  } catch (e) {
    logger.e('Error getting current position: $e');
    // Attempt to use a cached position as a fallback
    try {
      Position? cachedPosition = await Geolocator.getLastKnownPosition();
      if (cachedPosition != null) {
        logger.t(
            'Using cached position: ${cachedPosition.latitude}, ${cachedPosition.longitude}');
        return cachedPosition;
      } else {
        logger.i('No cached position available.');
      }
    } catch (e) {
      logger.e('Error getting cached position: $e');
    }
  }
  return Future.error(''); // Return null if both attempts fail
}

Future<List<Placemark>> getPlacemarkFromCoordinates(
    {required double latitude, required double longitude}) async {
  try {
    return await placemarkFromCoordinates(latitude, longitude);
  } catch (e) {
    return [];
  }
}

// Haversine formula to calculate distance
double calculateDistance(LatLng start, LatLng end) {
  const double earthRadius = 6371e3; // in meters
  double lat1 = start.latitude * math.pi / 180;
  double lat2 = end.latitude * math.pi / 180;
  double deltaLat = (end.latitude - start.latitude) * math.pi / 180;
  double deltaLon = (end.longitude - start.longitude) * math.pi / 180;

  double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLon / 2) *
          math.sin(deltaLon / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c; // returns distance in meters
}

// Calculate zoom level based on distance
double getZoomLevel(double distance) {
  if (distance < 1000) return 15; // close distance
  if (distance < 5000) return 12; // medium distance
  if (distance < 20000) return 10; // far distance
  return 8; // very far
}

dynamic localDateTimeFormat(DateTime dateTime) {
  try {
    return DateFormat('dd-MM-yyyy hh:mm aaa').format(dateTime);
  } catch (e) {
    return null;
  }
}

dynamic orderDateTimeFormat(DateTime dateTime) {
  try {
    return DateFormat("dd'th' MMM , hh:mm aaa.").format(dateTime);
  } catch (e) {
    return null;
  }
}

dynamic bookingDateTimeFormat(DateTime? dateTime) {
  if (dateTime == null) {
    return "N/A"; // Fallback for null DateTime
  }
  try {
    return DateFormat("yyyy/MM/d - hh:mm aaa.").format(dateTime);
  } catch (e) {
    return null; // Handle formatting errors
  }
}

info(String message) {
  logger.i(message);
}

error(String message) {
  logger.e(message);
}

String formatString(String input) {
  // Replace underscores with spaces
  String modifiedString = input.replaceAll('_', ' ');

  // Capitalize the first letter of each word
  modifiedString = modifiedString.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');

  return modifiedString;
}

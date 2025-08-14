import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Request background location permission
  var status = await Permission.locationAlways.request();
  if (status.isGranted) {
    print("Background location permission granted.");
  } else if (status.isDenied) {
    print("Background location permission denied.");
  } else if (status.isPermanentlyDenied) {
    print("Permission is permanently denied. You can open settings.");
    openAppSettings();
  }
}

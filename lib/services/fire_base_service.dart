import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:truklynk/services/token_service.dart';
import '../utils/helper_functions.dart';
import 'notification_service.dart';

class FireBaseService {
  final NotificationService notificationService = NotificationService();
  final TokenService tokenService = TokenService();
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController.broadcast();

  final List<Map<String, dynamic>> _pendingUpdates = [];

  // Expose the stream
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  List<Map<String, dynamic>> get pendingUpdates =>
      List.unmodifiable(_pendingUpdates);

  Future<void> firebaseInit() async {
    await Firebase.initializeApp();
    await _requestPermission(); // Request notification permissions
    await notificationService.localNotification();
    await _getFCMToken(); // Get FCM token
    onMessage();
    onMessageOpenedApp();
    // Call the background message handler separately
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: true,
      provisional: true,
    );
  }

  Future<void> _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      info("FCM Token: $token");
      tokenService.saveFCMToken(token);
    } else {
      error("Failed to get FCM token");
    }
  }

  void onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      info('Message opened app: ${message.notification?.title}');
      if (message.data.isNotEmpty) {
        _pendingUpdates.add(message.data);
        _messageStreamController.add(message.data);
      }
    });
  }

  void onMessage() {
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  }

  void _firebaseMessagingForegroundHandler(RemoteMessage message) {
    try {
      if (message.data.isNotEmpty) {
        _pendingUpdates.add(message.data);
        _messageStreamController.add(message.data);
      }
      notificationService.show(message);
    } catch (e) {
      error("Error handling foreground message: $e");
    }
  }

  void clearPendingUpdates() {
    _pendingUpdates.clear();
  }

  // Clean up resources
  void dispose() {
    _messageStreamController.close();
  }
}

// Background message handler must be a top-level function
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  NotificationService().show(message);
}

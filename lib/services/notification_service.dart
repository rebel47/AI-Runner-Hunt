import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> initFCM() async {
    await _fcm.requestPermission();
    await _fcm.setAutoInitEnabled(true);
    final token = await _fcm.getToken();
    // Save token to Firestore or backend as needed
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails('runner_channel', 'Runner Proximity', importance: Importance.max);
    const details = NotificationDetails(android: androidDetails);
    await _local.show(0, title, body, details);
  }

  Future<void> sendPushNotification(String token, String title, String body) async {
    // Use backend or FCM REST API to send push notification
    // Placeholder: implement server-side logic
  }

  Future<void> handleNotificationPermissions() async {
    final settings = await _fcm.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      throw 'Notification permission denied.';
    }
  }
}

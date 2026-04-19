import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future init() async {

    // طلب الصلاحيات
    await _messaging.requestPermission();

    // الاشتراك في إشعارات جميع المستخدمين
    await _messaging.subscribeToTopic("all_users");

    // تهيئة local notification
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _local.initialize(settings);

    // استقبال الإشعار عندما التطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      showNotification(
        message.notification?.title ?? "",
        message.notification?.body ?? "",
      );

    });

  }

  static Future showNotification(String title, String body) async {

    const androidDetails = AndroidNotificationDetails(
      "main_channel",
      "Main Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      0,
      title,
      body,
      details,
    );

  }

}
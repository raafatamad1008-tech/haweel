
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/AuthGate.dart';
import 'package:haweel/services/auth_service.dart';
import 'package:haweel/services/local_notification_service.dart';
import 'package:haweel/services/notification_service.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await LocalNotificationService.init();

  await NotificationService.init();

   await AuthService().initNotifications();
   await FirebaseMessaging.instance.subscribeToTopic("all_users");

runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ar", "SA"), // OR Locale('ar', 'AE') OR Other RTL locales
      ],
      locale: const Locale("ar", "SA"),
      theme: ThemeData(
        fontFamily: "Cairo"
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
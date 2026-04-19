import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haweel/pages/mobile/home_page.dart';

import '../pages/tablets/login_page.dart';
import '../pages/tablets/home_page_tablet.dart';
import '../pages/tablets/register_page.dart';
import '../pages/tablets/login_page_tablet.dart';
import '../responsive/responsive_layout.dart';
import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return ResponsiveLayout(
            mobile: LoginPage(),
            tablet: LoginPageTablet(),
          );
        }

        final user = snapshot.data!;

        return StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .snapshots(),
  builder: (context, userSnapshot) {
    if (userSnapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
      return RegisterPage(
        isGoogleUser: user.providerData
            .any((e) => e.providerId == "google.com"),
      );
    }

    final data = userSnapshot.data!.data() as Map<String, dynamic>?;

    if (data == null) {
      return RegisterPage(
        isGoogleUser: user.providerData
            .any((e) => e.providerId == "google.com"),
      );
    }

    final profileCompleted = data["profileCompleted"] ?? 0;
    final status = data["status"] ?? 1;

    /// ❌ الحساب غير مفعل
    if (status == 0) {
      return const Scaffold(
        body: Center(child: Text("الحساب غير مفعل")),
      );
    }

    /// ❌ لم يكمل التسجيل
    if (profileCompleted == 0) {
      return RegisterPage(
        isGoogleUser: user.providerData
            .any((e) => e.providerId == "google.com"),
      );
    }

    /// ✅ تمام
    return ResponsiveLayout(
      mobile: HomePage(),
      tablet: HomePageTablet(),
    );
  },
);
      },
    );
  }
}

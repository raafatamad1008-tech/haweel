import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// مراقبة حالة المستخدم
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تهيئة الإشعارات
  Future<void> initNotifications() async {

    try {

      // طلب صلاحية الاشعارات
      await _messaging.requestPermission();

      // الاشتراك في اشعارات جميع المستخدمين
      await _messaging.subscribeToTopic("all_users");

      // تحديث التوكن إذا تغير
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {

        final user = _auth.currentUser;

        if (user != null) {

          await _db.collection("users").doc(user.uid).set({
            "fcm_token": newToken,
            "updated_at": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print("FCM Token Updated: $newToken");
        }

      });

    } catch (e) {
      print("Notification init error: $e");
    }

  }

  /// حفظ FCM Token
  Future<void> saveFcmToken(String userId ) async {

    try {

      final token = await _messaging.getToken();



      if (token != null) {
       final userDoc = await _db.collection("users").doc(userId).get();
      int profileCompleted = 0; // القيمة الافتراضية إذا لم يكمل المستخدم

      if (userDoc.exists) {
        final data = userDoc.data();
        // إذا كانت هناك قيمة مسبقة لـ profileCompleted نحتفظ بها
        profileCompleted = data?["profileCompleted"] ?? 0;
        // هنا ممكن تضيف شرط لتحديد إذا المستخدم أكمل التسجيل فعليًا
        // مثال: إذا كان لديك حقل fullName أو emailVerified
        // إذا أكمل المستخدم:
        // profileCompleted = 0;
        // وإلا خلي كما هو:
      }


        await _db.collection("users").doc(userId).set({
          "fcm_token": token,
          "profileCompleted":  profileCompleted,
          "updated_at": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

      }

    } catch (e) {
      print("Save token error: $e");
    }

  }

  /// تسجيل دخول
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await saveFcmToken(credential.user!.uid);
    }

    return credential;
  }

  /// تسجيل حساب
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await saveFcmToken(credential.user!.uid);
    }

    return credential;
  }

  /// تسجيل الدخول عبر Google
  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("تم إلغاء تسجيل الدخول");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      await saveFcmToken(userCredential.user!.uid);
    }

    return userCredential;
  }

  /// تسجيل الدخول عبر Facebook
  Future<UserCredential?> signInWithFacebook() async {

    final LoginResult result =
        await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {

      final OAuthCredential credential =
          FacebookAuthProvider.credential(
              result.accessToken!.token);

      final userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await saveFcmToken(userCredential.user!.uid);
      }

      return userCredential;
    }

    return null;
  }

  /// تسجيل خروج
  Future<void> logout() async {

    await GoogleSignIn().signOut();
    await _auth.signOut();

  }

  /// المستخدم الحالي
  User? get currentUser => _auth.currentUser;
}
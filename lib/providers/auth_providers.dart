import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// مراقبة حالة تسجيل الدخول
final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// UserService Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// تحميل بيانات المستخدم مرة واحدة فقط
final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  final user = authState.value;
  if (user == null) return null;

  return await ref
      .watch(userServiceProvider)
      .getUser(user.uid);
});
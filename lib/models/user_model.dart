import 'package:cloud_firestore/cloud_firestore.dart';

/// ===============================
/// 🏷️ Badge Enum
/// ===============================
enum UserBadge {
  trusted,
  fastResponder,
  proExecutor,
  verified,
  fiveStars,
}

/// ===============================
/// 👤 User Model
/// ===============================
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String address;
  final String city;
  final String license;
  final String licenseExpireDate;
  final String? image;
  final int status;
  final double rating;
  final int membership;
  final List<UserBadge> badges;
  final int profileCompleted;
  final int completedContracts;
  final int bubblishedContract;
  final int responseTime;
  final bool isVerified;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.city,
    required this.license,
    required this.licenseExpireDate,
    this.image,
    required this.status,
    required this.rating,
    required this.membership,
    required this.badges,
    required this.profileCompleted,
    required this.completedContracts,
    required this.bubblishedContract,
    required this.responseTime,
    required this.isVerified,
    required this.createdAt,
    this.fcmToken,
  });

  /// 🔹 from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      license: map['license'] ?? '',
      licenseExpireDate: map['licenseExpireDate'] ?? '',
      image: map['image'],
      status: map['status'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      membership: map['membership'] ?? 0,
      profileCompleted: map['profileCompleted'] ?? 0,
      completedContracts: map['completedContracts'] ?? 0,
      bubblishedContract: map['bubblishedContract'] ?? 0,
      responseTime: map['responseTime'] ?? 999,
      isVerified: map['isVerified'] ?? false,
      badges: map['badges'] != null
          ? List<String>.from(map['badges'])
              .map((e) => UserBadge.values.firstWhere(
                    (b) => b.name == e,
                    orElse: () => UserBadge.trusted,
                  ))
              .toList()
          : [],
      fcmToken: map['fcm_token'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// 🔹 to Firestore
  Map<String, dynamic> toMap() {
    final map = {
      "uid": uid,
      "name": name,
      "email": email,
      "address": address,
      "city": city,
      "license": license,
      "licenseExpireDate": licenseExpireDate,
      "image": image,
      "status": status,
      "rating": rating,
      "membership": membership,
      "profileCompleted": profileCompleted,
      "completedContracts": completedContracts,
      "bubblishedContract": bubblishedContract,
      "responseTime": responseTime,
      "isVerified": isVerified,
      "badges": badges.map((e) => e.name).toList(),
      "createdAt": createdAt,
    };

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      map["fcm_token"] = fcmToken;
    }

    return map;
  }

  /// 🔹 Membership Label
  String get membershipLabel {
    switch (membership) {
      case 1:
        return "عضو نشط";
      case 2:
        return "عضو موثوق";
      default:
        return "عضو جديد";
    }
  }
}

/// ===============================
/// 🧠 Badge Service
/// ===============================
class BadgeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 تحديث الشارات بالكامل
  Future<void> updateUserBadges(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    final data = doc.data();

    if (data == null) return;

    List<UserBadge> badges = [];

    int completedContracts = data['completedContracts'] ?? 0;
    double rating = (data['rating'] ?? 0).toDouble();
    int responseTime = data['responseTime'] ?? 999;
    bool isVerified = data['isVerified'] ?? false;

    // 🏆 موثوق
    if (completedContracts >= 10 && rating >= 4.5) {
      badges.add(UserBadge.trusted);
    }

    // ⚡ سريع الرد
    if (responseTime <= 5) {
      badges.add(UserBadge.fastResponder);
    }

    // 🎯 منفذ محترف
    if (completedContracts >= 20) {
      badges.add(UserBadge.proExecutor);
    }

    // 🔐 موثق
    if (isVerified) {
      badges.add(UserBadge.verified);
    }

    // ⭐ تقييم كامل
    if (rating >= 5) {
      badges.add(UserBadge.fiveStars);
    }

    await _db.collection("users").doc(uid).update({
      "badges": badges.map((e) => e.name).toList(),
    });
  }

  /// 🔹 التحقق من وجود شارة
  bool hasBadge(List<UserBadge> badges, UserBadge badge) {
    return badges.contains(badge);
  }

  /// 🔹 إضافة شارة يدويًا
  Future<void> addBadge(String uid, UserBadge badge) async {
    final ref = _db.collection("users").doc(uid);

    await ref.update({
      "badges": FieldValue.arrayUnion([badge.name])
    });
  }

  /// 🔹 حذف شارة
  Future<void> removeBadge(String uid, UserBadge badge) async {
    final ref = _db.collection("users").doc(uid);

    await ref.update({
      "badges": FieldValue.arrayRemove([badge.name])
    });
  }
}
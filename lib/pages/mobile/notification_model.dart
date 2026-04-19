import 'dart:convert';

import 'package:flutter/widgets.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? contractId;
  final String? senderId;
  final DateTime createdAt;
  final bool isRead;
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.contractId,
    this.senderId,
    required this.createdAt,
    required this.isRead,
  });

  

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    ValueGetter<String?>? contractId,
    ValueGetter<String?>? senderId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      contractId: contractId != null ? contractId() : this.contractId,
      senderId: senderId != null ? senderId() : this.senderId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'contractId': contractId,
      'senderId': senderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      contractId: map['contractId'],
      senderId: map['senderId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppNotification.fromJson(String source) => AppNotification.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, body: $body, type: $type, contractId: $contractId, senderId: $senderId, createdAt: $createdAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AppNotification &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.type == type &&
      other.contractId == contractId &&
      other.senderId == senderId &&
      other.createdAt == createdAt &&
      other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      body.hashCode ^
      type.hashCode ^
      contractId.hashCode ^
      senderId.hashCode ^
      createdAt.hashCode ^
      isRead.hashCode;
  }
}

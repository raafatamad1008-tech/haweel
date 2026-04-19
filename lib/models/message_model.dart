import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderImage;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "sender_id": senderId,
      "sender_name": senderName,
      "sender_image": senderImage,
      "created_at": createdAt,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map["text"] ?? "",
      senderId: map["sender_id"] ?? "",
      senderName: map["sender_name"] ?? "",
      senderImage: map["sender_image"] ?? "",
      createdAt: (map["created_at"] as Timestamp).toDate(),
    );
  }
}
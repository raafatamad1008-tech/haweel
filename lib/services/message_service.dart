import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haweel/utils/notification_service.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String contractId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String text,
  }) async {
    /// حفظ الرسالة
    await _firestore
        .collection("contract_messages")
        .doc(contractId)
        .collection("messages")
        .add({
          "text": text,
          "sender_id": senderId,
          "sender_name": senderName,
          "sender_image": senderImage,
          "created_at": FieldValue.serverTimestamp(),
        });

    /// جلب token المستقبل
    final userDoc = await _firestore.collection("users").doc(receiverId).get();

    final token = userDoc.data()?["fcm_token"];

    if (token == null) return;

    NotificationService.sendMessageNotification(
      token,
      text,
      contractId,
      senderId,
      receiverId,
    );

    await FirebaseFirestore.instance.collection("notifications_log").add({
      "user_id": receiverId,
      "type": "message",
      "title": "رسالة جديدة",
      "body": text,
      "entity_id": contractId,
      "senderId": senderId,
      "is_read": false,
      "created_at": FieldValue.serverTimestamp(),
    });
  }

  /// stream الرسائل
  Stream<List<MessageModel>> getMessages(String contractId) {
    final ref = _firestore
        .collection("contract_messages")
        .doc(contractId)
        .collection("messages")
        .orderBy("created_at");

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}

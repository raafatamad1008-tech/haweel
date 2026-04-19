class NotificationModel {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String contractId;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.contractId,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "receiver_id": receiverId,
      "sender_id": senderId,
      "sender_name": senderName,
      "sender_image": senderImage,
      "contract_id": contractId,
      "message": message,
      "type": type,
      "is_read": isRead,
      "created_at": createdAt,
    };
  }
}
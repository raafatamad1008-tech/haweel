import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String id;
  final String title;
  final String description;
  final String city;
  final String date;
  final String time;
  final String orderNumber;
  final int status;
  final String uid;
  final String executorId;
  final DateTime createdAt;

  ContractModel({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.date,
    required this.time,
    required this.orderNumber,
    required this.status,
    required this.uid, 
    required this.executorId, 
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "city": city,
      "date": date,
      "time": time,
      "order_number": orderNumber,
      "status": status,
      "uid": uid,
      "executor_id": executorId,
      "createdAt": createdAt,
    };
  }

  factory ContractModel.fromMap(Map<String, dynamic> map, String id) {
    return ContractModel(
      id: id,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      city: map["city"] ?? "",
      date: map["date"] ?? "",
      time: map["time"] ?? "",
      orderNumber: map["order_number"] ?? "",
      status: map["status"] ?? 0,
      uid: map["uid"] ?? "",
      executorId: map["executor_id"] ?? "",
       createdAt: map['createdAt'] != null
    ? (map['createdAt'] as Timestamp).toDate()
    : DateTime.now(), 
      
    );
  }
}
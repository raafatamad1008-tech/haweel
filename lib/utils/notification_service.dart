import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class NotificationService {

  static const String baseUrl =
      "https://matheon.online/haweel/public/api/notification";

  // ارسال رسالة
  static Future sendMessageNotification(
      String token,
      String body,
      String contractId,
      String senderId,
      String reciverId,
      ) async {

    final url = Uri.parse("$baseUrl/message");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "token": token,
        "body": body,
        "contract_id": contractId,
        "sender_id": senderId,
        "reciver_id": reciverId,
      }),
    );

    print(response.body);
  }

  // اشعار عقد جديد
  static Future sendContractNotification(
      String title,
      ) async {

    final url = Uri.parse("$baseUrl/contract");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "title": title,
      }),
    );

    print(response.body);
  }

  // اشعار تفعيل العضوية
  static Future sendMembershipNotification(
      String token
      ) async {

    final url = Uri.parse("$baseUrl/membership");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "token": token
      }),
    );

    print(response.body);
  }

  // اكتمال تنفيذ العقد
  static Future sendContractCompletedNotification(
      String token,
      String contractId
      ) async {

    final url = Uri.parse("$baseUrl/contract-completed");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "token": token,
        "contract_id": contractId
      }),
    );

    print(response.body);
  }


   static sendNotification(String receiverId , String contractId) async{
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;


        final userDoc =
      await _firestore.collection("users").doc(receiverId).get();

  final token = userDoc.data()?["fcm_token"];
                  
    sendContractCompletedNotification(token, contractId);
  }
}
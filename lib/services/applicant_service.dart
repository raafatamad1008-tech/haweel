import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haweel/models/applicant_model.dart';

class ApplicantService {
  // final _db = FirebaseFirestore.instance;
  final _applicants = FirebaseFirestore.instance.collection("applicants");

  Stream<List<ApplicantModel>> getApplicants(String contractId) {
    return FirebaseFirestore.instance
        .collection("applicants")
        .where("contractId", isEqualTo: contractId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ApplicantModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> apply(String contractId, String userId) async {
    await _applicants.add({
      "contractId": contractId,
      "userId": userId,
      "selected": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptApplicant(String contractId, String userId) async {
    final db = FirebaseFirestore.instance;

    /// تحديث العقد
    await db.collection("contracts").doc(contractId).update({
      "executor_id": userId,
      "status": 1,
    });

    /// تحديد المتقدم الفائز
    final applicants = await db
        .collection("applicants")
        .where("contractId", isEqualTo: contractId)
        .get();

    for (var doc in applicants.docs) {
      if (doc["userId"] == userId) {
        await doc.reference.update({"selected": true});
      } else {
        await doc.reference.update({"selected": false});
      }
    }

    // await FirebaseFirestore.instance.collection("notifications").add({
    //   "user_id": userId,
    //   "type": "contract_accepted",
    //   "title": "تم قبول العقد",
    //   "body": "تم قبول عقدك",
    //   "entity_id": contractId,
    //   "is_read": false,
    //   "created_at": FieldValue.serverTimestamp(),
    // });
  }

  Future<void> updateContractStatus(String contractId, int status) async {
    final db = FirebaseFirestore.instance;

    await db.collection("contracts").doc(contractId).update({"status": status});
  }

  Future<bool> hasApplied(String contractId, String userId) async {
    final result = await FirebaseFirestore.instance
        .collection("applicants")
        .where("contractId", isEqualTo: contractId)
        .where("userId", isEqualTo: userId)
        .get();

    return result.docs.isNotEmpty;
  }
}

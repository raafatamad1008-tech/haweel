import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/models/applicant_model.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/services/applicant_service.dart';

final applicantsProvider = StreamProvider.family<List<ApplicantModel>, String>((
  ref,
  contractId,
) {
  return ApplicantService().getApplicants(contractId);
});

final appliedContractsProvider =
    StreamProvider.family<List<ContractModel>, String>((ref, uid) {
      final db = FirebaseFirestore.instance;

      return db
          .collection("applicants")
          .where("userId", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            if (snapshot.docs.isEmpty) {
              return [];
            }

            final contractIds = snapshot.docs
                .map((doc) => doc["contractId"] as String)
                .toList();

            final contractsSnapshot = await db
                .collection("contracts")
                .where(FieldPath.documentId, whereIn: contractIds)
                .get();

            final contracts = contractsSnapshot.docs.map((doc) {
              return ContractModel.fromMap(doc.data(), doc.id);
            }).toList();

            /// ترتيب تنازلي
            // contracts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return contracts;
          });
    });

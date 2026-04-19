import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contract_model.dart';
import '../services/contract_service.dart';

final contractServiceProvider = Provider((ref) {
  return ContractService();
});

final contractsProvider = StreamProvider<List<ContractModel>>((ref) {
  final service = ref.read(contractServiceProvider);
  final uid = FirebaseAuth.instance.currentUser!.uid;

  return service.getContracts(uid);
});

final contractProvider = StreamProvider.family<ContractModel, String>((
  ref,
  contractId,
) {
  return FirebaseFirestore.instance
      .collection("contracts")
      .doc(contractId)
      .snapshots()
      .map((doc) {
        return ContractModel.fromMap(doc.data()!, doc.id);
      });
});

final contractsByUserProvider =
    StreamProvider.family<List<ContractModel>, String>((ref, uid) {
      return FirebaseFirestore.instance
          .collection("contracts")
          .orderBy("createdAt", descending: true)
          .where("uid", isEqualTo: uid)
          // .orderBy("date", descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ContractModel.fromMap(doc.data(), doc.id);
            }).toList();
          });
    });

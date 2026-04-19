import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haweel/utils/notification_service.dart';
import '../models/contract_model.dart';

class ContractService {
  final _contracts = FirebaseFirestore.instance.collection("contracts");

  // Future<void> createContract(ContractModel contract) async {
  //   await _contracts.add(contract.toMap());

  //   NotificationService.sendContractNotification(
  //     contract.title
  //   );

    
  // }

  Future<String> createContract(ContractModel contract) async {

  final doc = await FirebaseFirestore.instance
      .collection("contracts")
      .add(contract.toMap());

      NotificationService.sendContractNotification(
      contract.title
    );

  return doc.id;
}

  // Stream<List<ContractModel>> getContracts(String uid) {
  //   return _contracts
  //       // .where("uid", isEqualTo: uid)
  //       .where("status", isEqualTo: 0) // اخفاء المنتهي
  //       .orderBy("createdAt", descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return ContractModel.fromMap(doc.data(), doc.id);
  //     }).toList();
  //   });
  // }

  Stream<List<ContractModel>> getContracts(String uid) {
  return _contracts
      // .where("uid", isEqualTo: uid)
      .where("status", isEqualTo: 0) // اخفاء المنتهي
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
          return ContractModel.fromMap(doc.data(), doc.id);
        })
        .where((contract) => !_isContractExpired(contract.date, contract.time))
        .toList();
      });
}

// دالة لتحويل الوقت العربي إلى DateTime
bool _isContractExpired(String date, String time) {
  try {
    final dateParts = date.split('-');
    final time24 = _convertArabicTimeTo24(time);

    if (dateParts.length != 3 || time24 == null) return false;

    final timeParts = time24.split(':');

    final contractDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    return contractDateTime.isBefore(DateTime.now());
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

// في ملف contract_service.dart
Future<void> updateContract(ContractModel contract) async {
  try {
    await FirebaseFirestore.instance
        .collection('contracts')
        .doc(contract.id)
        .update({
          'title': contract.title,
          'description': contract.description,
          'city': contract.city,
          'date': contract.date,
          'time': contract.time,
          'orderNumber': contract.orderNumber,
          // لا نقوم بتحديث uid, executorId, status, createdAt
        });
  } catch (e) {
    print('Error updating contract: $e');
    rethrow;
  }
}

// دالة لتحويل الوقت من صيغة "5:10 م" إلى صيغة 24 ساعة "17:10"
String? _convertArabicTimeTo24(String timeStr) {
  try {
    // تنظيف النص من المسافات الزائدة
    timeStr = timeStr.trim();
    
    // فصل الوقت عن الجزء (ص/م)
    String timePart;
    String period;
    
    if (timeStr.contains(' ')) {
      final parts = timeStr.split(' ');
      timePart = parts[0];
      period = parts[1];
    } else if (timeStr.contains('ص') || timeStr.contains('م')) {
      // إذا كان بدون مسافة مثل "5:10م"
      if (timeStr.contains('ص')) {
        final index = timeStr.indexOf('ص');
        timePart = timeStr.substring(0, index);
        period = 'ص';
      } else {
        final index = timeStr.indexOf('م');
        timePart = timeStr.substring(0, index);
        period = 'م';
      }
    } else {
      return null;
    }
    
    // تقسيم الساعات والدقائق
    final timeParts = timePart.split(':');
    if (timeParts.length != 2) return null;
    
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    
    // التحويل إلى نظام 24 ساعة
    if (period == 'م' && hours != 12) {
      hours += 12;
    } else if (period == 'ص' && hours == 12) {
      hours = 0;
    }
    
    // تنسيق الوقت بصيغة 24 ساعة
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  } catch (e) {
    print('Error converting time: $e');
    return null;
  }
}

  Stream<List<ContractModel>> getContractsByUID(String uid) {
    return _contracts
        .where("uid", isEqualTo: uid)
        .where("status", isNotEqualTo: 2) // اخفاء المنتهي
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ContractModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // دالة حذف العقد من Firebase
Future<void> deleteContract(String contractId) async {
  try {
    await FirebaseFirestore.instance
        .collection('contracts')
        .doc(contractId)
        .delete();
    print('Contract deleted successfully');
  } catch (e) {
    print('Error deleting contract: $e');
    throw Exception('Failed to delete contract');
  }
}

  Future<void> updateStatus(String id, int status) async {
    await _contracts.doc(id).update({"status": status});
  }
}
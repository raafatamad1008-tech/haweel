import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/tablets/notifications_page.dart';
import 'package:haweel/widgets/add_contract_dialog.dart';
import 'package:haweel/widgets/contract_canceled.dart';
import 'package:haweel/widgets/contract_comlete.dart';
import 'package:haweel/providers/contract_provider.dart';
import 'package:haweel/widgets/Applicant_excuation_tools.dart';
import 'package:haweel/widgets/applicants.dart';
import 'package:haweel/widgets/apply_for_contract.dart';
import 'package:haweel/widgets/bubblier_excuation_tools.dart';
import 'package:haweel/widgets/info_card.dart';
import 'package:haweel/widgets/marked_contract_as_compelete.dart';
import 'package:haweel/widgets/notifications_icon.dart';
import 'package:haweel/widgets/show_delete_confirmation_dialog.dart';
import 'package:haweel/widgets/user_card.dart';
import 'package:haweel/widgets/wait_confiurm.dart';

class ContractDetailsPage extends ConsumerWidget {
  final String contractId;

  ContractDetailsPage({super.key, required this.contractId});

  // الحصول على userId بشكل آمن
  String? get _userId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cancelContract(
    BuildContext context,
    String contractId,
    String excId,
  ) async {
    try {
      // تحديث حالة العقد إلى ملغي
      await FirebaseFirestore.instance
          .collection('contracts')
          .doc(contractId)
          .update({'status': 4});

      final querySnapshot = await FirebaseFirestore.instance
          .collection("applicants")
          .where("userId", isEqualTo: excId)
          .where("contractId", isEqualTo: contractId)
          .limit(1) // مهم لأنه سجل واحد
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء العقد بنجاح'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إلغاء العقد: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractProvider(contractId));
    final currentUserId = _userId;

    print("mobile contract id: $contractId");

    return contractAsync.when(
      data: (contract) {
        // التحقق من وجود العقد
        if (contract == null) {
          // إذا تم حذف العقد، نعود للصفحة السابقة
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف هذا العقد'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
          return const SizedBox.shrink();
        }

        // التحقق من وجود المستخدم
        if (currentUserId == null) {
          return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
        }

        // التحقق مما إذا كان المستخدم الحالي هو صاحب العقد
        bool isOwner = contract.uid == currentUserId;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Spacer(),
                            Text(
                              "تفاصيل العقد",
                              style: TextStyle(fontSize: 24),
                            ),
                            Spacer(),
                            if (!isOwner)
                              NotificationsIcon(context, currentUserId),
                            if (isOwner)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (isOwner &&
                                        value == 'cancel' &&
                                        contract.status != 4) {
                                      await _cancelContract(
                                        context,
                                        contract.id!,
                                        contract.executorId ?? '',
                                      );
                                    } else if (value == 'edit') {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AddContractDialog(
                                          contract: contract,
                                        ),
                                      );
                                      print('تعديل العقد: ${contract.id}');
                                    } else if (value == 'delete') {
                                      // عرض مربع حوار للتأكيد قبل الحذف
                                      final shouldDelete =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (context) =>
                                                ShowDeleteConfirmationDialog(
                                                  contract: contract,
                                                ),
                                          );

                                      if (shouldDelete == true &&
                                          context.mounted) {
                                        // العودة للصفحة السابقة بعد الحذف
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    }
                                  },
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(0, 40),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  itemBuilder: (context) => [
                                    if (isOwner && contract.status != 4 && contract.status != 0 && contract.status == 1 && contract.status != 3)
                                      PopupMenuItem(
                                        value: 'cancel',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel,
                                              size: 20,
                                              color: Color.fromARGB(
                                                255,
                                                243,
                                                89,
                                                33,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'الغاء العقد',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'تعديل العقد',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'حذف العقد',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Text(
                          contract.title ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Text(
                          contract.description ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 97, 97, 97),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.3,
                        children: [
                          infoCard(
                            "المدينة",
                            contract.city ?? '',
                            Icons.location_on,
                            Colors.purpleAccent,
                          ),
                          infoCard(
                            "التاريخ",
                            contract.date ?? '',
                            Icons.calendar_today,
                            Colors.amber,
                          ),
                          infoCard(
                            "الوقت",
                            contract.time ?? '',
                            Icons.access_time,
                            Colors.green,
                          ),
                          infoCard(
                            "رقم العقد",
                            contract.orderNumber ?? '',
                            Icons.description,
                            Colors.blueAccent,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (contract.uid != null && contract.uid!.isNotEmpty)
                        UserCard(uid: contract.uid!, title: "ناشر العقد"),
                      SizedBox(height: 20),
                      if (contract.executorId != null &&
                          contract.executorId!.isNotEmpty)
                        UserCard(
                          uid: contract.executorId!,
                          title: "منفذ العقد",
                        ),
                      SizedBox(height: 20),
                      if (currentUserId != contract.uid)
                        ApplyForContract(
                          userId: currentUserId,
                          contract: contract,
                        ),
                      if (contract.status == 0) Applicants(contract: contract),
                      if (contract.status == 3) ContractComlete(),
                      if (contract.status == 4) ContractCanceled(),
                      if (contract.status == 1 &&
                          currentUserId == contract.executorId)
                        ApplicantExcuationTools(contract: contract),
                      if (contract.status == 1 && currentUserId == contract.uid)
                        BubblierExcuationTools(contract: contract),
                      if (contract.status == 2 &&
                          currentUserId == contract.executorId)
                        WaitConfiurm(),
                      if (contract.status == 2 && currentUserId == contract.uid)
                        MarkedContractAsCompelete(contract: contract),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // معالجة الخطأ عند عدم وجود العقد
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            // التحقق من نوع الخطأ
            String errorMessage = '';

            if (error is Exception) {
              errorMessage = error.toString();
            } else if (error is String) {
              errorMessage = error;
            } else if (error != null) {
              errorMessage = error.toString();
            } else {
              errorMessage = 'حدث خطأ غير متوقع';
            }

            // التحقق مما إذا كان الخطأ بسبب عدم وجود العقد
            if (errorMessage.contains('NOT_FOUND') ||
                errorMessage.contains('permission') ||
                errorMessage.contains('لم يتم العثور')) {
              // العودة للصفحة السابقة
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم حذف هذا العقد أو لا يوجد لديك صلاحية الوصول',
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              // أخطاء أخرى
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ: $errorMessage'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  duration: Duration(seconds: 3),
                ),
              );

              // العودة للصفحة السابقة بعد ثانية
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            }
          }
        });

        // إرجاع SizedBox فارغ لتجنب الشاشة السوداء
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل البيانات...'),
              ],
            ),
          ),
        );
      },
    );
  }
}

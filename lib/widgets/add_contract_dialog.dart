import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/user_model.dart';
import 'package:haweel/services/user_service.dart';
import 'package:haweel/widgets/input.dart';
import '../models/contract_model.dart';
import '../services/contract_service.dart';

class AddContractDialog extends StatefulWidget {
  final ContractModel? contract; // إذا كان موجوداً، نكون في وضع التعديل
  
  const AddContractDialog({super.key, this.contract});

  @override
  State<AddContractDialog> createState() => _AddContractDialogState();
}

class _AddContractDialogState extends State<AddContractDialog> {
  late final TextEditingController title;
  late final TextEditingController description;
  late final TextEditingController city;
  late final TextEditingController date;
  late final TextEditingController time;
  late final TextEditingController orderNumber;

  final service = ContractService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // تهيئة الـ Controllers مع البيانات الموجودة إذا كنا في وضع التعديل
    title = TextEditingController(text: widget.contract?.title ?? '');
    description = TextEditingController(text: widget.contract?.description ?? '');
    city = TextEditingController(text: widget.contract?.city ?? '');
    date = TextEditingController(text: widget.contract?.date ?? '');
    time = TextEditingController(text: widget.contract?.time ?? '');
    orderNumber = TextEditingController(text: widget.contract?.orderNumber ?? '');
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    city.dispose();
    date.dispose();
    time.dispose();
    orderNumber.dispose();
    super.dispose();
  }

  // دالة التحقق من صحة المدخلات
  bool _validateInputs() {
    if (title.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال عنوان العقد', Colors.red);
      return false;
    }
    if (description.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال وصف العقد', Colors.red);
      return false;
    }
    if (city.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال المدينة', Colors.red);
      return false;
    }
    if (date.text.trim().isEmpty) {
      _showSnackBar('الرجاء اختيار تاريخ تنفيذ العقد', Colors.red);
      return false;
    }
    if (time.text.trim().isEmpty) {
      _showSnackBar('الرجاء اختيار وقت تنفيذ العقد', Colors.red);
      return false;
    }
    if (orderNumber.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال رقم العقد', Colors.red);
      return false;
    }
    return true;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateInputs()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        _showSnackBar('يرجى تسجيل الدخول أولاً', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final user = await UserService().getUser(uid);
      
      if (user == null) {
        _showSnackBar('لم يتم العثور على بيانات المستخدم', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // التحقق من المدينة (فقط للإضافة وليس للتعديل)
      if (widget.contract == null && user.city != city.text.trim()) {
        _showDialog(
          'تحذير',
          'لا يمكنك إضافة عقد في مدينة مختلفة عن مدينتك',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (widget.contract != null) {
        // وضع التعديل - تحديث العقد الموجود
        final updatedContract = ContractModel(
          id: widget.contract!.id,
          title: title.text.trim(),
          description: description.text.trim(),
          city: city.text.trim(),
          date: date.text.trim(),
          time: time.text.trim(),
          orderNumber: orderNumber.text.trim(),
          status: widget.contract!.status,
          uid: widget.contract!.uid,
          executorId: widget.contract!.executorId,
          createdAt: widget.contract!.createdAt,
        );

        await service.updateContract(updatedContract);
        
        if (!mounted) return;
        _showSnackBar('تم تعديل العقد بنجاح', Colors.green);
        Navigator.pop(context, true); // إرجاع true للتأكيد على التعديل
      } else {
        // وضع الإضافة - إنشاء عقد جديد
        final contract = ContractModel(
          id: "",
          title: title.text.trim(),
          description: description.text.trim(),
          city: city.text.trim(),
          date: date.text.trim(),
          time: time.text.trim(),
          orderNumber: orderNumber.text.trim(),
          status: 0,
          uid: uid,
          executorId: "",
          createdAt: DateTime.now(),
        );

        final contractId = await service.createContract(contract);

        // إضافة إشعار للعقد الجديد
        await FirebaseFirestore.instance
            .collection("notifications_log")
            .add({
              "type": "contract",
              "title": "عقد جديد",
              "body": title.text.trim(),
              "entity_id": contractId,
              "is_global": true,
              "is_read": false,
              "created_at": FieldValue.serverTimestamp(),
            });

        if (!mounted) return;
        _showSnackBar('تم إضافة العقد بنجاح', Colors.green);
        Navigator.pop(context, true); // إرجاع true للتأكيد على الإضافة
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[400],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contract != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FluentIcons.contact_card_ribbon_24_regular,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          isEditing ? "تعديل العقد" : "إضافة عقد",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Input(
                        controller: title,
                        label: "عنوان العقد",
                        icon: FluentIcons.contract_down_left_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Input(
                        controller: description,
                        label: "الوصف",
                        icon: FluentIcons.text_description_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                        lineHeight: 3,
                      ),
                      const SizedBox(height: 10),
                      Input(
                        controller: city,
                        label: "المدينة",
                        icon: FluentIcons.city_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Input(
                        controller: date,
                        label: "تاريخ تنفيذ العقد",
                        icon: FluentIcons.calendar_date_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                        type: "date",
                      ),
                      const SizedBox(height: 10),
                      Input(
                        controller: time,
                        label: "الوقت",
                        icon: FluentIcons.timer_10_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                        type: "time",
                      ),
                      const SizedBox(height: 10),
                      Input(
                        controller: orderNumber,
                        label: "رقم العقد",
                        icon: FluentIcons.timer_10_24_regular,
                        iconColor: AppColors.primary,
                        borderColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? "تعديل" : "إضافة"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text("إلغاء"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
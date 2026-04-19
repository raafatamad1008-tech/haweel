import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/pages/tablets/contract_chat_page.dart';
import 'package:haweel/pages/tablets/contract_details_page.dart';
import 'package:haweel/pages/tablets/membership_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // التحقق من وجود المستخدم
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('يرجى تسجيل الدخول'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.roundBackground,
                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Spacer(),
                    const Text("الإشعارات", style: TextStyle(fontSize: 24)),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notifications_log")
                      .where(
                        Filter.or(
                          Filter("user_id", isEqualTo: userId),
                          Filter("is_global", isEqualTo: true),
                        ),
                      )
                      .orderBy("created_at", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data!.docs;

                    if (notifications.isEmpty) {
                      return const Center(child: Text("لا توجد إشعارات"));
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final doc = notifications[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    const Color.fromARGB(255, 232, 218, 252),
                                    const Color.fromARGB(255, 245, 239, 255),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    data['type'] == 'contract'
                                        ? FluentIcons.certificate_24_regular
                                        : data['type'] == 'message'
                                        ? FluentIcons.chat_24_regular
                                        : Icons.notifications,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    data["title"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(data["body"] ?? ""),
                                ),
                                trailing: data["is_read"] == false
                                    ? const Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Colors.red,
                                      )
                                    : null,
                                onTap: () async {
                                  // تعليم الإشعار كمقروء
                                  await FirebaseFirestore.instance
                                      .collection("notifications_log")
                                      .doc(doc.id)
                                      .update({"is_read": true});

                                  final type = data["type"];
                                  final title = data["body"];
                                  final entityId = data["entity_id"];

                                  // فتح الصفحة المناسبة
                                  if (type == "contract" && entityId != null) {
                                    // التحقق من وجود العقد قبل فتح الصفحة
                                    try {
                                      final doc1 = await FirebaseFirestore.instance
                                          .collection("contracts")
                                          .doc(entityId)
                                          .get();

                                      // التحقق من وجود المستند
                                      if (!doc1.exists) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم حذف هذا العقد من قبل الناشر'),
                                              backgroundColor: Colors.orange,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // التحقق من وجود البيانات
                                      final data1 = doc1.data();
                                      if (data1 == null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('بيانات العقد غير متوفرة'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // فتح صفحة تفاصيل العقد
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ContractDetailsPage(contractId: entityId),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('حدث خطأ: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } 
                                  else if (type == "message" && entityId != null) {
                                    // للرسائل، نحتاج إلى جلب العقد أولاً
                                    try {
                                      final doc1 = await FirebaseFirestore.instance
                                          .collection("contracts")
                                          .doc(entityId)
                                          .get();

                                      if (!doc1.exists) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم حذف العقد المرتبط بهذه الرسالة'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      final data1 = doc1.data();
                                      if (data1 == null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('بيانات العقد غير متوفرة'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      final contract = ContractModel.fromMap(data1, doc1.id);
                                      
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ContractChatPage(
                                              contract: contract,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('حدث خطأ: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } 
                                  else if (type == "membership") {
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MembershipPage(
                                            membershipType: title ?? "",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
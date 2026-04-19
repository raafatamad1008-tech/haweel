import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/mobile/notifications_page.dart';
import 'package:haweel/providers/applicants_provider.dart';
import 'package:haweel/widgets/project_card_widget.dart';

class MyApllicant extends StatefulWidget {
  final String uid;
  const MyApllicant({super.key, required this.uid});

  @override
  State<MyApllicant> createState() => _MyApllicantState();
}

class _MyApllicantState extends State<MyApllicant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.roundBackground,
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
              
                        Spacer(),
                          Row(
                    children: [
                      Text(
                        "تقديماتي",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                        Spacer(),
              
                        Container(
                              decoration: BoxDecoration(
                                color: AppColors.roundBackground,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(FluentIcons.alert_24_regular),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("notifications_log")
                                        .where(
                                          Filter.or(
                                            Filter(
                                              "user_id",
                                              isEqualTo: widget.uid,
                                            ),
                                            Filter(
                                              "is_global",
                                              isEqualTo: true,
                                            ),
                                          ),
                                        )
                                        .where("is_read", isEqualTo: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return const SizedBox();

                                      int count = snapshot.data!.docs.length;

                                      print(count);

                                      if (count == 0) return const SizedBox();

                                      return Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          count.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
          ),
            
              
                SizedBox(height: 20),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final contracts = ref.watch(appliedContractsProvider(widget.uid));
            
                      return contracts.when(
                        data: (data) {
                          // لا توجد عقود
                          if (data.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 70,
                                    color: Colors.grey.shade400,
                                  ),
            
                                  const SizedBox(height: 16),
            
                                  Text(
                                    "لا توجد عقود",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
            
                                  const SizedBox(height: 8),
            
                                  Text(
                                    "عليك ان تقد علي عقود اولا حتي تظهر معك هنا",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
            
                          // عرض العقود
                          return Padding(
                            padding: const EdgeInsets.symmetric (horizontal:  16.0),
                            child: SizedBox(
                              width: 500,
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final contract = data[index];
                                          
                                  return ProjectCardWidget(context, contract: contract, currentUserId: widget.uid);
                                },
                              ),
                            ),
                          );
                        },
            
                        // أثناء التحميل
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
            
                        // في حال وجود خطأ
                        error: (e, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red.shade300,
                              ),
            
                              const SizedBox(height: 12),
            
                              const Text(
                                "حدث خطأ أثناء تحميل العقود",
                                style: TextStyle(fontSize: 16),
                              ),
            
                              const SizedBox(height: 6),
            
                              Text(
                                e.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      )),
    );

  }
}
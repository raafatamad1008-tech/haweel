import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/providers/contract_provider.dart';
import 'package:haweel/widgets/add_contract_dialog.dart';
import 'package:haweel/widgets/notifications_icon.dart';
import 'package:haweel/widgets/project_card_widget.dart';

class MyContract extends StatefulWidget {
  final String uid;
  final ContractModel? contract;
  const MyContract({super.key, required this.uid, this.contract});

  @override
  State<MyContract> createState() => _MyContractState();
}

class _MyContractState extends State<MyContract> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddContractDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(FluentIcons.add_24_regular, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
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
                          "عقودي",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    NotificationsIcon(context, widget.uid),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final contracts = ref.watch(
                    contractsByUserProvider(widget.uid),
                  );

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
                                "اضغط على زر + لإضافة أول عقد",
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
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final contract = data[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: ProjectCardWidget(
                              context,
                              contract: contract,
                              currentUserId: widget.uid,
                            ),
                          );
                        },
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
        ),
      ),
    );
  }
}

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/applicant_model.dart';
import 'package:haweel/services/applicant_service.dart';

class ApplicantDialog extends StatelessWidget {
  final ApplicantModel applicant;
  final String contractId;

  const ApplicantDialog({
    super.key,
    required this.applicant,
    required this.contractId,
  });

  Future<Map<String, dynamic>?> getUser() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(applicant.userId)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final user = snapshot.data!;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    width: 120,
                    child: Stack(
                      alignment: AlignmentGeometry.bottomCenter,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(user["image"]),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: user['membership'] == 0
                              ? Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.roundBackground,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.new_releases,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                )
                              : user['membership'] == 1
                              ? Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.bolt,
                                    size: 32,
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      128,
                                      55,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    size: 32,
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      174,
                                      0,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        user["name"] ?? "مستخدم",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(122, 234, 225, 248),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(124, 195, 152, 255),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              FluentIcons.city_24_regular,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            "المدينة ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            user["city"] ?? "",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(122, 234, 225, 248),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(124, 195, 152, 255),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              FluentIcons.certificate_24_regular,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            "رقم الرخصة",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          subtitle: Text(
                            user["license"] ?? "",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(122, 234, 225, 248),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(124, 195, 152, 255),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              FluentIcons.calculator_24_regular,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            "تاريخ الانتهاء",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          subtitle: Text(
                            user["license_export_date"] ?? "",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.grey)],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  
                                  await ApplicantService().acceptApplicant(
                                    contractId,
                                    applicant.userId,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }

                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text("قبول العرض"),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.background,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text("الغاء"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

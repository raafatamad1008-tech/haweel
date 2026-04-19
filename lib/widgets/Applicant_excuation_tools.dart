import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/pages/tablets/contract_chat_page.dart';
import 'package:haweel/services/applicant_service.dart';
import 'package:haweel/utils/notification_service.dart';

class ApplicantExcuationTools extends StatefulWidget {
  final ContractModel contract;
  const ApplicantExcuationTools({super.key, required this.contract});

  @override
  State<ApplicantExcuationTools> createState() =>
      _ApplicantExcuationToolsState();
}

class _ApplicantExcuationToolsState extends State<ApplicantExcuationTools> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.roundBackground,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Icon(
              FluentIcons.flag_pride_progress_28_filled,
              size: 64,
              color: AppColors.primary,
            ),
         
          ),
        

        SizedBox(height: 20),

        Text(
          "العقد تحت التنفيذ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () async {
                  await ApplicantService().updateContractStatus(
                    widget.contract.id,
                    2,
                  );

                 NotificationService.sendNotification(
                    widget.contract.executorId,
                    widget.contract.id
                  );

 
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text("تم التنفيذ"),
              ),
            ),

            SizedBox(width: 20),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () async {
                   Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  ContractChatPage(contract: widget.contract ),
                              ),
                            );
                 
                  // المراسلة هنا
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 160, 104, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text("مراسلة"),
              ),
            ),
          ],
        ),
      ],
    );
  }

 
}

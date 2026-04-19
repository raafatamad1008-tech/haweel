import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/services/applicant_service.dart';
import 'package:haweel/utils/notification_service.dart';

class MarkedContractAsCompelete extends StatefulWidget {
  final ContractModel contract;
  const MarkedContractAsCompelete({super.key, required this.contract});

  @override
  State<MarkedContractAsCompelete> createState() =>
      _MarkedContractAsCompeleteState();
}

class _MarkedContractAsCompeleteState extends State<MarkedContractAsCompelete> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Icon(
            FluentIcons.flag_pride_progress_28_filled,
            size: 64,
            color: const Color.fromARGB(255, 255, 205, 55),
          ),
        ),

        SizedBox(height: 20),

        Text(
          "تم تنفيذ العقد",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () async {
                await ApplicantService().updateContractStatus(
                    widget.contract.id,
                    3,
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
            child: const Text("تأشير العقد كمنفذ"),
          ),
        ),
      ],
    );
  }
}

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/pages/tablets/contract_chat_page.dart';

class BubblierExcuationTools extends StatefulWidget {
  final ContractModel contract;
  const BubblierExcuationTools({super.key, required this.contract});

  @override
  State<BubblierExcuationTools> createState() => _BubblierExcuationToolsState();
}

class _BubblierExcuationToolsState extends State<BubblierExcuationTools> {
  @override
  Widget build(BuildContext context) {
    return Column(
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

        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContractChatPage(
                    contract: widget.contract,
                  ),
                ),
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
            child: const Text("مراسلة المنفذ"),
          ),
        ),
      ],
    );
  }
}

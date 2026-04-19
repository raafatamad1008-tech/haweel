import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';

class ContractComlete extends StatefulWidget {
  const ContractComlete({super.key});

  @override
  State<ContractComlete> createState() => _ContractComleteState();
}

class _ContractComleteState extends State<ContractComlete> {
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
          child: IconButton(
            icon: Icon(
              FluentIcons.checkbox_checked_24_regular,
              size: 64,
              color: AppColors.primary,
            ),
            onPressed: () async {},
          ),
        ),

        SizedBox(height: 20),

        Text(
          "تم تنفيذ العقد",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';

class WaitConfiurm extends StatefulWidget {
  const WaitConfiurm({super.key});

  @override
  State<WaitConfiurm> createState() => _WaitConfiurmState();
}

class _WaitConfiurmState extends State<WaitConfiurm> {
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
              FluentIcons.info_24_regular,
              size: 64,
              color: const Color.fromARGB(255, 255, 95, 55),
            ),
            onPressed: () async {},
          ),
        ),

        SizedBox(height: 20),

        Text(
          "انتظار التأكيد",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

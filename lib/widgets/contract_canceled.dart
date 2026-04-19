import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';

class ContractCanceled extends StatefulWidget {
  const ContractCanceled({super.key});

  @override
  State<ContractCanceled> createState() => _ContractCanceledState();
}

class _ContractCanceledState extends State<ContractCanceled> {
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
              Icons.cancel,
              size: 64,
              color: const Color.fromARGB(255, 255, 95, 55),
            ),
            onPressed: () async {},
          ),
        ),

        SizedBox(height: 20),

        Text(
          "تم الغاء العقد",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

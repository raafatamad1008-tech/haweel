import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';

Widget headerAppBar(BuildContext context, String title) {
  return Container(
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
        Text(title, style: TextStyle(fontSize: 24)),
        Spacer(),

        Container(
          decoration: BoxDecoration(
            color: AppColors.roundBackground,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: IconButton(
            icon: Icon(FluentIcons.mail_24_regular),
            onPressed: () {},
          ),
        ),
        SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.roundBackground,
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: IconButton(
            icon: Icon(FluentIcons.alert_24_regular),
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}

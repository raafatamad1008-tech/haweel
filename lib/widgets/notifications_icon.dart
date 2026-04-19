import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/mobile/notifications_page.dart';

// ignore: non_constant_identifier_names
Widget NotificationsIcon(BuildContext context, String userId) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.roundBackground,
      borderRadius: BorderRadius.all(Radius.circular(100)),
    ),
    child: Stack(
      children: [
        IconButton(
          icon: Icon(FluentIcons.alert_24_regular),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("notifications_log")
              .where(
                Filter.or(
                  Filter("user_id", isEqualTo: userId),
                  Filter("is_global", isEqualTo: true),
                ),
              )
              .where("is_read", isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

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
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
    ),
  );
}

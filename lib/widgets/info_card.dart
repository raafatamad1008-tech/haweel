import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';

Widget infoCard(String title, String value, IconData icon , Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(41, 138, 55, 255),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          

        Text(title, style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255))),

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 234, 234, 234),
          ),
        ),
          ]
        
        )
      ],
    ),
  );
}

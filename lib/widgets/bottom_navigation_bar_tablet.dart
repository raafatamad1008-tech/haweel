import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/pages/tablets/my_apllicant.dart';
import 'package:haweel/pages/tablets/my_contract.dart';
import 'package:haweel/widgets/add_contract_dialog.dart';

Widget buildBottomBarTablet(BuildContext context, String userId) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // زر العقود
            _buildActionButton(
              context: context,
              icon: FluentIcons.contact_card_ribbon_24_regular,
              label: 'عقودي',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyContract(uid: userId),
                  ),
                );
              },
            ),
            
            const Spacer(),
            
            // زر الإضافة الرئيسي
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddContractDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FluentIcons.add_24_regular,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // زر المتقدمين
            _buildActionButton(
              context: context,
              icon: FluentIcons.contract_down_left_24_regular,
              label: 'متقدمين',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApllicant(uid: userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
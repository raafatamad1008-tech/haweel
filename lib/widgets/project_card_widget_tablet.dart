import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/pages/tablets/contract_details_page.dart';
import 'package:haweel/widgets/add_contract_dialog.dart';
import 'package:haweel/widgets/show_delete_confirmation_dialog.dart'; // تأكد من وجود هذا الـ service

Widget ProjectCardWidgetTablet(BuildContext context, 
    {required ContractModel contract, required String currentUserId}) {
  // Generate a consistent color based on contract title or id
  final List<List<Color>> colorGradients = [
    [Color(0xFF667EEA), Color(0xFF764BA2)], // Purple gradient
    [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink gradient
    [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Blue gradient
    [Color(0xFF43E97B), Color(0xFF38F9D7)], // Green gradient
    [Color(0xFFFA709A), Color(0xFFFEE140)], // Orange gradient
    [Color(0xFF30CFD0), Color(0xFF330867)], // Teal gradient
    [Color(0xFFa8c0ff), Color(0xFF3f2b96)], // Light purple gradient
    [Color(0xFFfccb90), Color(0xFFd57eeb)], // Peach gradient
  ];
  
  int colorIndex = contract.title.hashCode.abs() % colorGradients.length;
  List<Color> selectedGradient = colorGradients[colorIndex];
  
  // التحقق مما إذا كان المستخدم الحالي هو صاحب العقد
  bool isOwner = contract.uid == currentUserId;
  
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    child: Material(
      elevation: 8,
      shadowColor: selectedGradient[0].withOpacity(0.3),
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContractDetailsPage(contractId: contract.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selectedGradient,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // زر القائمة في الأعلى على اليسار
              if (isOwner)
                Positioned(
                  top: 24,
                  left: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {

                          showDialog(context: context, builder: (context) =>  AddContractDialog(contract: contract,));
                          // فتح صفحة تعديل العقد
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => EditContractPage(contract: contract),
                          //   ),
                          // );
                          print('تعديل العقد: ${contract.id}');
                        } else if (value == 'delete') {
                          // عرض مربع حوار للتأكيد قبل الحذف
                          ShowDeleteConfirmationDialog( contract:  contract);
                        }
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      offset: const Offset(0, 40),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'تعديل العقد',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'حذف العقد',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            FluentIcons.contact_card_ribbon_24_regular,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            contract.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info section with modern design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 33, 33, 33).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInfoItem(
                                icon: Icons.location_on,
                                text: contract.date,
                                color: Colors.white,
                              ),
                              const Spacer(),
                              _buildInfoItem(
                                icon: FluentIcons.timer_24_regular,
                                text: contract.time,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: Colors.white.withOpacity(0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoItem(
                                icon: FluentIcons.city_24_regular,
                                text: contract.city,
                                color: Colors.white,
                              ),
                              const Spacer(),
                              // Status indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                     Text(
                                       contract.status == 0 ? 'مفتوج' : contract.status == 1 ? 'قيد التنفيذ' : contract.status == 2 ? 'مكتمل' : 'ملغي',
                                     
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



Widget _buildInfoItem({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Row(
    children: [
      Icon(icon, size: 16, color: color.withOpacity(0.9)),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color.withOpacity(0.95),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
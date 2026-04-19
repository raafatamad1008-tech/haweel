// في ملف show_delete_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/services/contract_service.dart';

class ShowDeleteConfirmationDialog extends StatefulWidget {
  final ContractModel contract;
  
  const ShowDeleteConfirmationDialog({super.key, required this.contract});

  @override
  State<ShowDeleteConfirmationDialog> createState() => _ShowDeleteConfirmationDialogState();
}

class _ShowDeleteConfirmationDialogState extends State<ShowDeleteConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[400],
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'حذف العقد',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'هل أنت متأكد من حذف هذا العقد؟',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200] ?? Colors.red),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.red[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.contract.title ?? 'بدون عنوان',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا يمكن التراجع عن هذا الإجراء',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('حذف'),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ContractService().deleteContract(widget.contract.id);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
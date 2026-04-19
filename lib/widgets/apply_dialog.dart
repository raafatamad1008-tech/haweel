import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/applicant_service.dart';

class ApplyDialog extends StatefulWidget {

  final String contractId;
  final String contractName;

  const ApplyDialog({
    super.key,
    required this.contractId,
    required this.contractName,
  });

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      title: const Text("التقديم على العقد"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(
            "أنت على وشك التقديم على العقد:\n${widget.contractName}",
            textAlign: TextAlign.center,
          ),

        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("إلغاء"),
        ),

        isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              )
            : ElevatedButton(

                onPressed: () async {

                  setState(() {
                    isLoading = true;
                  });

                  final user = FirebaseAuth.instance.currentUser;

                  await ApplicantService().apply(
                    widget.contractId,
                    user!.uid,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {
                    
                  });
                },

                child: const Text("إرسال"),
              ),

      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/services/applicant_service.dart';
import 'package:haweel/widgets/apply_dialog.dart';

class ApplyForContract extends StatefulWidget {
  final ContractModel contract;
  final String userId;
  const ApplyForContract({
    super.key,
    required this.userId,
    required this.contract,
  });

  @override
  State<ApplyForContract> createState() => _ApplyForContractState();
}

class _ApplyForContractState extends State<ApplyForContract> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey)],
      ),
      child: Row(
        children: [
          if (widget.contract.status == 0)
            FutureBuilder<bool>(
              future: ApplicantService().hasApplied(widget.contract.id, widget. userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final applied = snapshot.data!;

                if (applied) {
                  return const SizedBox(); // يخفي الزر
                }

                return Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ApplyDialog(
                          contractId: widget. contract.id,
                          contractName:widget. contract.title,
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text("التقديم علي العقد"),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

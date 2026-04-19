import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haweel/core/constants/app_colors.dart';
import 'package:haweel/models/contract_model.dart';
import 'package:haweel/providers/message_provider.dart';

class ChatInput extends ConsumerStatefulWidget {
  final String contractId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String receiverId;
  final ContractModel contract;

  const ChatInput({
    super.key,
    required this.contractId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.receiverId, required this.contract,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "اكتب رسالة",
                labelStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(
                  FluentIcons.mail_24_regular,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                final text = controller.text;

                if (text.isEmpty) return;

                final service = ref.read(messageServiceProvider);
print("sender_id : ${widget.senderId}");
print("sender_id : ${widget.receiverId}");

final receiverId =
    widget.senderId == widget.contract.uid
        ? widget. contract.executorId
        : widget. contract.uid;

                await service.sendMessage(
                  contractId: widget.contractId,
                  senderId: widget.senderId,
                  senderName: widget.senderName,
                  senderImage: widget.senderImage,
                  text: text,
                  receiverId: receiverId,
                );

                controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

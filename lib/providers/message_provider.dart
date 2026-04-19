import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

final messageServiceProvider = Provider((ref) {
  return MessageService();
});

final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, contractId) {

  final service = ref.watch(messageServiceProvider);

  return service.getMessages(contractId);
});
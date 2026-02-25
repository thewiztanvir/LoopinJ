import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import 'chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final cryptoService = ref.watch(cryptoServiceProvider);
  return ChatService(cryptoService);
});

final chatRoomsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  return ref.watch(chatServiceProvider).getChatRooms();
});

final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  return ref.watch(chatServiceProvider).getMessages(chatRoomId);
});

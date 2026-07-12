import 'package:sanad/features/chat/data/models/chat_model.dart';
import 'package:sanad/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> getMyChats(String userId);
  Stream<List<MessageModel>> getChatMessages(String chatId);
  Stream<ChatModel> getChatStream(String chatId);
  Future<void> sendMessage(MessageModel message);
  Future<void> markMessagesAsRead(String chatId, String userId);
}

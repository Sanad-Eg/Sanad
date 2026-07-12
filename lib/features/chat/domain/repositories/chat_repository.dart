import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatEntity>>> getMyChats(String userId);
  Stream<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId);
  Stream<Either<Failure, ChatEntity>> getChatStream(String chatId);
  Future<Either<Failure, void>> sendMessage(MessageEntity message);
  Future<Either<Failure, void>> markMessagesAsRead(String chatId, String userId);
}

import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String chatId) {
    return repository.getChatMessages(chatId);
  }
}

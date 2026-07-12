import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class GetChatStreamUseCase {
  final ChatRepository repository;

  GetChatStreamUseCase(this.repository);

  Stream<Either<Failure, ChatEntity>> call(String chatId) {
    return repository.getChatStream(chatId);
  }
}

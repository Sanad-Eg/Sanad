import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId, String userId) async {
    return await repository.markMessagesAsRead(chatId, userId);
  }
}

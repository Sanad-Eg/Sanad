import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class GetMyChatsUseCase {
  final ChatRepository repository;

  GetMyChatsUseCase(this.repository);

  Stream<Either<Failure, List<ChatEntity>>> call(String userId) {
    return repository.getMyChats(userId);
  }
}

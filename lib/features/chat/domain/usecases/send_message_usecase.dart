import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(MessageEntity message) async {
    return await repository.sendMessage(message);
  }
}

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sanad/features/chat/data/models/message_model.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';

class FirebaseChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  FirebaseChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ChatEntity>>> getMyChats(String userId) {
    return remoteDataSource.getMyChats(userId).map<Either<Failure, List<ChatEntity>>>(
      (chatModels) {
        return Right(chatModels);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return Left(ChatFailure(error.message ?? 'حدث خطأ في جلب المحادثات'));
      }
      return Left(ChatFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId) {
    return remoteDataSource.getChatMessages(chatId).map<Either<Failure, List<MessageEntity>>>(
      (messageModels) {
        return Right(messageModels);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return Left(ChatFailure(error.message ?? 'حدث خطأ في جلب الرسائل'));
      }
      return Left(ChatFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, ChatEntity>> getChatStream(String chatId) {
    return remoteDataSource.getChatStream(chatId).map<Either<Failure, ChatEntity>>(
      (chatModel) {
        return Right(chatModel);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return Left(ChatFailure(error.message ?? 'حدث خطأ في جلب المحادثة'));
      }
      return Left(ChatFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageEntity message) async {
    try {
      final model = MessageModel(
        id: message.id,
        chatId: message.chatId,
        senderId: message.senderId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
      );
      await remoteDataSource.sendMessage(model);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ChatFailure(e.message ?? 'حدث خطأ أثناء إرسال الرسالة'));
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String chatId, String userId) async {
    try {
      await remoteDataSource.markMessagesAsRead(chatId, userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ChatFailure(e.message ?? 'حدث خطأ أثناء تحديث حالة الرسائل'));
    } catch (e) {
      return Left(ChatFailure(e.toString()));
    }
  }
}

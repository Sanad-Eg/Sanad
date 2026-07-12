import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:sanad/features/notifications/domain/entities/notification_entity.dart';
import 'package:sanad/features/notifications/domain/repositories/notification_repository.dart';

class FirebaseNotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  FirebaseNotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotificationsStream(String userId) {
    return remoteDataSource.getNotificationsStream(userId).map<Either<Failure, List<NotificationEntity>>>(
      (models) {
        return Right(models);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return Left(NotificationFailure(error.message ?? 'حدث خطأ أثناء جلب الإشعارات'));
      }
      return Left(NotificationFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId, String userId) async {
    try {
      await remoteDataSource.markAsRead(notificationId, userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(NotificationFailure(e.message ?? 'حدث خطأ أثناء تحديث حالة الإشعار'));
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      await remoteDataSource.markAllAsRead(userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(NotificationFailure(e.message ?? 'حدث خطأ أثناء تحديث جميع الإشعارات'));
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }
}

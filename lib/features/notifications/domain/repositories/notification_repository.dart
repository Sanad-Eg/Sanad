import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<Either<Failure, List<NotificationEntity>>> getNotificationsStream(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId, String userId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
}

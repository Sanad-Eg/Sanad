import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/notifications/domain/entities/notification_entity.dart';
import 'package:sanad/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsStreamUseCase {
  final NotificationRepository repository;

  GetNotificationsStreamUseCase(this.repository);

  Stream<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return repository.getNotificationsStream(userId);
  }
}

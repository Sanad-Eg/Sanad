import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String notificationId,
    required String userId,
  }) async {
    return await repository.markAsRead(notificationId, userId);
  }
}

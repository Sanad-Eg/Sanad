import 'package:sanad/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotificationsStream(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
}

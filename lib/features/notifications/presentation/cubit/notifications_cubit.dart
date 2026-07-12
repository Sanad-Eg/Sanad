import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/notifications/domain/usecases/get_notifications_stream_usecase.dart';
import 'package:sanad/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:sanad/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsStreamUseCase _getNotificationsStream;
  final MarkNotificationAsReadUseCase _markNotificationAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsRead;

  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({
    required GetNotificationsStreamUseCase getNotificationsStream,
    required MarkNotificationAsReadUseCase markNotificationAsRead,
    required MarkAllNotificationsAsReadUseCase markAllNotificationsAsRead,
  })  : _getNotificationsStream = getNotificationsStream,
        _markNotificationAsRead = markNotificationAsRead,
        _markAllNotificationsAsRead = markAllNotificationsAsRead,
        super(const NotificationsState());

  void watchNotifications(String userId) {
    _notificationsSubscription?.cancel();
    emit(state.copyWith(status: NotificationsStatus.loading, errorMessage: () => null));

    _notificationsSubscription = _getNotificationsStream(userId).listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: NotificationsStatus.error,
            errorMessage: () => failure.message,
          )),
          (notifications) {
            final unread = notifications.where((n) => !n.isRead).length;
            emit(state.copyWith(
              status: NotificationsStatus.success,
              notifications: notifications,
              unreadCount: unread,
              errorMessage: () => null,
            ));
          },
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final result = await _markNotificationAsRead(
      notificationId: notificationId,
      userId: userId,
    );
    result.fold(
      (_) {},
      (_) => null, // Stream will update UI automatically
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final result = await _markAllNotificationsAsRead(userId);
    result.fold(
      (_) {},
      (_) => null, // Stream will update UI automatically
    );
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}

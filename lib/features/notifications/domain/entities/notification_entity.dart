import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // e.g., 'booking', 'chat', 'system'
  final String? relatedId; // e.g., bookingId or chatId
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        relatedId,
        createdAt,
        isRead,
      ];
}

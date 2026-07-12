import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final String bookingId;
  final String clientId;
  final String helperId;
  final String clientName;
  final String helperName;
  final String? lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.helperId,
    required this.clientName,
    required this.helperName,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        clientId,
        helperId,
        clientName,
        helperName,
        lastMessage,
        updatedAt,
        unreadCount,
      ];
}

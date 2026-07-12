import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.bookingId,
    required super.clientId,
    required super.helperId,
    required super.clientName,
    required super.helperName,
    super.lastMessage,
    required super.updatedAt,
    required super.unreadCount,
  });

  factory ChatModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ChatModel(
      id: id,
      bookingId: json['bookingId'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      helperId: json['helperId'] as String? ?? '',
      clientName: json['clientName'] as String? ?? 'العميل',
      helperName: json['helperName'] as String? ?? 'المساعد',
      lastMessage: json['lastMessage'] as String?,
      updatedAt: _toDateTime(json['updatedAt']) ?? DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'clientId': clientId,
      'helperId': helperId,
      'clientName': clientName,
      'helperName': helperName,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'unreadCount': unreadCount,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

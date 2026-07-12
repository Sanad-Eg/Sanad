import 'package:equatable/equatable.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';

enum ChatRoomStatus { initial, loading, success, error }

class ChatRoomState extends Equatable {
  final ChatRoomStatus status;
  final List<MessageEntity> messages;
  final String? errorMessage;
  final bool isSending;
  final ChatEntity? chat;

  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isSending = false,
    this.chat,
  });

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    List<MessageEntity>? messages,
    String? Function()? errorMessage,
    bool? isSending,
    ChatEntity? Function()? chat,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSending: isSending ?? this.isSending,
      chat: chat != null ? chat() : this.chat,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, isSending, chat];
}

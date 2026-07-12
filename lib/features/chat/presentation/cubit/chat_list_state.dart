import 'package:equatable/equatable.dart';
import 'package:sanad/features/chat/domain/entities/chat_entity.dart';

enum ChatListStatus { initial, loading, success, error }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatEntity> chats;
  final String? errorMessage;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.errorMessage,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatEntity>? chats,
    String? Function()? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, chats, errorMessage];
}

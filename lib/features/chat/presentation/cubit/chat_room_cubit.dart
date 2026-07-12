import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/chat/domain/entities/message_entity.dart';
import 'package:sanad/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/get_chat_stream_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final GetChatMessagesUseCase _getChatMessages;
  final SendMessageUseCase _sendMessage;
  final GetChatStreamUseCase _getChatStream;
  final MarkMessagesAsReadUseCase _markMessagesAsRead;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _chatSubscription;

  ChatRoomCubit({
    required GetChatMessagesUseCase getChatMessages,
    required SendMessageUseCase sendMessage,
    required GetChatStreamUseCase getChatStream,
    required MarkMessagesAsReadUseCase markMessagesAsRead,
  })  : _getChatMessages = getChatMessages,
        _sendMessage = sendMessage,
        _getChatStream = getChatStream,
        _markMessagesAsRead = markMessagesAsRead,
        super(const ChatRoomState());

  void watchMessages(String chatId) {
    _messagesSubscription?.cancel();
    _chatSubscription?.cancel();
    emit(state.copyWith(status: ChatRoomStatus.loading, errorMessage: () => null));

    _chatSubscription = _getChatStream(chatId).listen(
      (result) {
        result.fold(
          (_) {},
          (chat) => emit(state.copyWith(chat: () => chat)),
        );
      },
      onError: (_) {},
    );

    _messagesSubscription = _getChatMessages(chatId).listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: ChatRoomStatus.error,
            errorMessage: () => failure.message,
          )),
          (messages) => emit(state.copyWith(
            status: ChatRoomStatus.success,
            messages: messages,
            errorMessage: () => null,
          )),
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: ChatRoomStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  Future<void> sendMessage(MessageEntity message) async {
    emit(state.copyWith(isSending: true));
    final result = await _sendMessage(message);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isSending: false,
          status: ChatRoomStatus.error,
          errorMessage: () => failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isSending: false));
      },
    );
  }

  Future<void> markAsRead(String chatId, String userId) async {
    final result = await _markMessagesAsRead(chatId, userId);
    result.fold(
      (_) {},
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatSubscription?.cancel();
    return super.close();
  }
}

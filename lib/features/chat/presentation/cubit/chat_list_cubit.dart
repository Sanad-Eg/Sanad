import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/chat/domain/usecases/get_my_chats_usecase.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final GetMyChatsUseCase _getMyChats;
  StreamSubscription? _chatsSubscription;

  ChatListCubit({
    required GetMyChatsUseCase getMyChats,
  })  : _getMyChats = getMyChats,
        super(const ChatListState());

  void watchChats(String userId) {
    _chatsSubscription?.cancel();
    emit(state.copyWith(status: ChatListStatus.loading, errorMessage: () => null));

    _chatsSubscription = _getMyChats(userId).listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: ChatListStatus.error,
            errorMessage: () => failure.message,
          )),
          (chats) => emit(state.copyWith(
            status: ChatListStatus.success,
            chats: chats,
            errorMessage: () => null,
          )),
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: ChatListStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}

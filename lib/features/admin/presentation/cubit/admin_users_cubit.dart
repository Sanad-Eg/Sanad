import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/admin/domain/usecases/approve_helper_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final GetUsersUseCase _getUsers;
  final ApproveHelperUseCase _approveHelper;
  StreamSubscription? _usersSubscription;

  AdminUsersCubit({
    required GetUsersUseCase getUsers,
    required ApproveHelperUseCase approveHelper,
  })  : _getUsers = getUsers,
        _approveHelper = approveHelper,
        super(const AdminUsersInitial());

  void watchUsers() {
    emit(const AdminUsersLoading());
    _usersSubscription?.cancel();
    _usersSubscription = _getUsers().listen(
      (result) {
        result.fold(
          (failure) => emit(AdminUsersError(failure.message)),
          (users) => emit(AdminUsersLoaded(users)),
        );
      },
      onError: (error) {
        emit(AdminUsersError(error.toString()));
      },
    );
  }

  Future<void> approveHelper(String uid) async {
    final result = await _approveHelper(uid);
    result.fold(
      (failure) => emit(AdminUsersError(failure.message)),
      (_) {
        // The stream will auto-update the UI; no manual state change needed.
      },
    );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}

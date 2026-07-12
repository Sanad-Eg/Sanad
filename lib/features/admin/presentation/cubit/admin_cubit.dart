import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/admin/domain/usecases/get_pending_helpers_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/update_helper_verification_status_usecase.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final GetPendingHelpersUseCase _getPendingHelpers;
  final UpdateHelperVerificationStatusUseCase _updateHelperVerificationStatus;

  StreamSubscription? _helpersSubscription;

  AdminCubit({
    required GetPendingHelpersUseCase getPendingHelpers,
    required UpdateHelperVerificationStatusUseCase updateHelperVerificationStatus,
  })  : _getPendingHelpers = getPendingHelpers,
        _updateHelperVerificationStatus = updateHelperVerificationStatus,
        super(const AdminState());

  void watchPendingHelpers() {
    _helpersSubscription?.cancel();
    emit(state.copyWith(status: AdminStatus.loading, errorMessage: () => null));

    _helpersSubscription = _getPendingHelpers().listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminStatus.error,
            errorMessage: () => failure.message,
          )),
          (helpers) => emit(state.copyWith(
            status: AdminStatus.success,
            pendingHelpers: helpers,
            errorMessage: () => null,
          )),
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: AdminStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  Future<void> verifyHelper(String helperId, bool isApproved) async {
    emit(state.copyWith(isActionLoading: true));
    final status = isApproved ? 'approved' : 'rejected';
    
    final result = await _updateHelperVerificationStatus(
      helperId: helperId,
      status: status,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint('[AdminCubit] Update verification status failed: ${failure.message}');
        emit(state.copyWith(
          isActionLoading: false,
          status: AdminStatus.error,
          errorMessage: () => failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isActionLoading: false));
      },
    );
  }

  @override
  Future<void> close() {
    _helpersSubscription?.cancel();
    return super.close();
  }
}

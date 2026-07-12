import 'package:equatable/equatable.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';

enum AdminStatus { initial, loading, success, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<UserEntity> pendingHelpers;
  final String? errorMessage;
  final bool isActionLoading;

  const AdminState({
    this.status = AdminStatus.initial,
    this.pendingHelpers = const [],
    this.errorMessage,
    this.isActionLoading = false,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<UserEntity>? pendingHelpers,
    String? Function()? errorMessage,
    bool? isActionLoading,
  }) {
    return AdminState(
      status: status ?? this.status,
      pendingHelpers: pendingHelpers ?? this.pendingHelpers,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [status, pendingHelpers, errorMessage, isActionLoading];
}

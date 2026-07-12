import 'package:equatable/equatable.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';

enum AuthStatus { checking, initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  // For helper registration multi-step flow
  final int helperRegisterStep; // 1, 2, or 3
  final String? helperName;
  final String? helperPhone;
  final String? helperEmail;
  final String? helperPassword;
  final String? helperAboutMe;
  final double? helperHourlyRate;
  final List<String> helperSpecialties;
  final List<String> helperServiceAreas;
  final String? helperIdFrontPath;
  final String? helperIdBackPath;
  final String? helperSelfieWithIdPath;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.helperRegisterStep = 1,
    this.helperName,
    this.helperPhone,
    this.helperEmail,
    this.helperPassword,
    this.helperAboutMe,
    this.helperHourlyRate,
    this.helperSpecialties = const [],
    this.helperServiceAreas = const [],
    this.helperIdFrontPath,
    this.helperIdBackPath,
    this.helperSelfieWithIdPath,
  });

  const AuthState.initial() : this();

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool clearError = false,
    int? helperRegisterStep,
    String? helperName,
    String? helperPhone,
    String? helperEmail,
    String? helperPassword,
    String? helperAboutMe,
    double? helperHourlyRate,
    List<String>? helperSpecialties,
    List<String>? helperServiceAreas,
    String? helperIdFrontPath,
    String? helperIdBackPath,
    String? helperSelfieWithIdPath,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      helperRegisterStep: helperRegisterStep ?? this.helperRegisterStep,
      helperName: helperName ?? this.helperName,
      helperPhone: helperPhone ?? this.helperPhone,
      helperEmail: helperEmail ?? this.helperEmail,
      helperPassword: helperPassword ?? this.helperPassword,
      helperAboutMe: helperAboutMe ?? this.helperAboutMe,
      helperHourlyRate: helperHourlyRate ?? this.helperHourlyRate,
      helperSpecialties: helperSpecialties ?? this.helperSpecialties,
      helperServiceAreas: helperServiceAreas ?? this.helperServiceAreas,
      helperIdFrontPath: helperIdFrontPath ?? this.helperIdFrontPath,
      helperIdBackPath: helperIdBackPath ?? this.helperIdBackPath,
      helperSelfieWithIdPath: helperSelfieWithIdPath ?? this.helperSelfieWithIdPath,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        helperRegisterStep,
        helperName,
        helperPhone,
        helperEmail,
        helperPassword,
        helperAboutMe,
        helperHourlyRate,
        helperSpecialties,
        helperServiceAreas,
        helperIdFrontPath,
        helperIdBackPath,
        helperSelfieWithIdPath,
      ];
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sanad/features/auth/domain/usecases/login_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/register_helper_usecase.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_state.dart';
import 'package:sanad/core/services/push_notification_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _login;
  final RegisterClientUseCase _registerClient;
  final RegisterHelperUseCase _registerHelper;
  final LogoutUseCase _logout;
  final UploadProfileImageUseCase _uploadProfileImage;
  final FirebaseAuth _firebaseAuth;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserEntity?>? _userDocSubscription;

  AuthCubit({
    required LoginUseCase login,
    required RegisterClientUseCase registerClient,
    required RegisterHelperUseCase registerHelper,
    required LogoutUseCase logout,
    required UploadProfileImageUseCase uploadProfileImage,
    required FirebaseAuth firebaseAuth,
    required AuthRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _login = login,
        _registerClient = registerClient,
        _registerHelper = registerHelper,
        _logout = logout,
        _uploadProfileImage = uploadProfileImage,
        _firebaseAuth = firebaseAuth,
        _remoteDataSource = remoteDataSource,
        _authRepository = authRepository,
        super(const AuthState(status: AuthStatus.checking)) {
    checkAuth();
  }

  // ── Auth Persistence Check ───────────────────────────
  Future<void> checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Cancel any previous subscription to avoid duplicates
    _authStateSubscription?.cancel();

    // 1. Try checking currentUser immediately to resolve faster
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _resolveUser(currentUser);
    } else {
      // 2. If currentUser is null, wait for authStateChanges stream,
      //    but schedule a 2.5 second fallback timer so the app never hangs on Splash screen.
      Timer(const Duration(milliseconds: 2500), () {
        if (state.status == AuthStatus.checking && !isClosed) {
          emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
        }
      });
    }

    // 3. Listen for subsequent auth state changes
    _authStateSubscription = _firebaseAuth.authStateChanges().listen(
      (firebaseUser) {
        if (firebaseUser != null) {
          _resolveUser(firebaseUser);
        } else {
          if (!isClosed) {
            emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
          }
        }
      },
      onError: (_) {
        if (!isClosed) {
          emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
        }
      },
    );
  }

  Future<void> _resolveUser(User firebaseUser) async {
    _userDocSubscription?.cancel();
    _userDocSubscription = _remoteDataSource.watchCurrentUser(firebaseUser.uid).listen(
      (userModel) {
        if (!isClosed) {
          if (userModel != null) {
            debugPrint('[AuthCubit] Stream updated: verificationStatus=${userModel.verificationStatus}');
            // Force a new state object so BlocListener always fires,
            // even if only a nested field like verificationStatus changed.
            emit(AuthState(
              status: AuthStatus.authenticated,
              user: userModel,
            ));
            PushNotificationService().syncTokenToFirestore();
          } else {
            // Document missing in Firestore — treat as unauthenticated
            emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
          }
        }
      },
      onError: (e) {
        debugPrint('[AuthCubit] Stream error: $e');
        if (!isClosed) {
          emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
        }
      },
    );
  }

  // ── Login ────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _login(email: email, password: password);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
        PushNotificationService().syncTokenToFirestore();
      },
    );
  }

  // ── Client Registration ──────────────────────────────
  Future<void> registerAsClient({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String primaryNeedType,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerClient(
      name: name,
      phone: phone,
      email: email,
      password: password,
      primaryNeedType: primaryNeedType,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
        PushNotificationService().syncTokenToFirestore();
      },
    );
  }

  // ── Helper Registration Step-by-Step ─────────────────
  void saveHelperStep1({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    emit(state.copyWith(
      helperRegisterStep: 2,
      helperName: name,
      helperPhone: phone,
      helperEmail: email,
      helperPassword: password,
      clearError: true,
    ));
  }

  void saveHelperStep2({
    required String aboutMe,
    required double hourlyRate,
    required List<String> specialties,
    required List<String> serviceAreas,
  }) {
    emit(state.copyWith(
      helperRegisterStep: 3,
      helperAboutMe: aboutMe,
      helperHourlyRate: hourlyRate,
      helperSpecialties: specialties,
      helperServiceAreas: serviceAreas,
      clearError: true,
    ));
  }

  Future<void> submitHelperRegistration({
    required String idFrontPath,
    required String idBackPath,
    required String selfieWithIdPath,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerHelper(
      name: state.helperName!,
      phone: state.helperPhone!,
      email: state.helperEmail!,
      password: state.helperPassword!,
      aboutMe: state.helperAboutMe!,
      hourlyRate: state.helperHourlyRate!,
      specialties: state.helperSpecialties,
      serviceAreas: state.helperServiceAreas,
      idFrontPath: idFrontPath,
      idBackPath: idBackPath,
      selfieWithIdPath: selfieWithIdPath,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
        PushNotificationService().syncTokenToFirestore();
      },
    );
  }

  void goBackHelperStep() {
    if (state.helperRegisterStep > 1) {
      emit(state.copyWith(helperRegisterStep: state.helperRegisterStep - 1));
    }
  }

  // ── Upload Profile Image ─────────────────────────────
  Future<void> uploadProfileImage(String filePath) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _uploadProfileImage(uid: uid, filePath: filePath);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // Re-fetch the updated user document to refresh profileImageUrl in state
        checkAuth();
      },
    );
  }

  // ── Update Profile Name ─────────────────────────────
  Future<void> updateProfileName(String newName) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _remoteDataSource.updateUserFields(
        uid: uid,
        data: {'name': newName},
      );
      await checkAuth();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'فشل تحديث الاسم: $e',
        ));
      }
    }
  }

  // ── Change Password ─────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AuthStatus.authenticated)),
    );
  }

  // ── Forgot Password ─────────────────────────────
  Future<void> resetPassword(String email) async {
    debugPrint('FORGOT_PASS_CUBIT: resetPassword called with email: $email');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _authRepository.sendPasswordResetEmail(email);
    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('Reset Password Error: ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(status: AuthStatus.initial, clearError: true)),
    );
  }

  // ── Logout ───────────────────────────────────────────
  Future<void> logout() async {
    _userDocSubscription?.cancel();
    await _logout();
    if (!isClosed) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    _userDocSubscription?.cancel();
    return super.close();
  }
}

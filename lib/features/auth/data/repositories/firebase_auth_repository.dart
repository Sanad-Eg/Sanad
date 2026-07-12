import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sanad/features/auth/data/models/user_model.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
///
/// Responsibilities:
///   - Delegates Firebase Auth calls (sign-in, register, sign-out) to [FirebaseAuth].
///   - Delegates Firestore persistence to [AuthRemoteDataSource].
///   - Maps all exceptions to typed [Failure] subclasses so the domain & UI
///     layers never deal with raw Firebase exceptions.
class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final AuthRemoteDataSource _remoteDataSource;

  FirebaseAuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required AuthRemoteDataSource remoteDataSource,
  })  : _firebaseAuth = firebaseAuth,
        _remoteDataSource = remoteDataSource;

  // ── Register Client ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String primaryNeedType,
  }) async {
    try {
      // 1. Create the Firebase Auth account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Build a typed UserModel with the generated UID
      final userModel = UserModel.newClient(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        primaryNeedType: primaryNeedType,
      );

      // 3. Persist the document to Firestore's `users` collection
      await _remoteDataSource.createUserInFirestore(userModel);

      // 4. Return as UserEntity (domain type) — no Data types leak upward
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Login with Email ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in via Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Fetch the full user profile from Firestore
      final userModel = await _remoteDataSource.getUserFromFirestore(uid);

      if (userModel == null) {
        return const Left(
          AuthFailure('لم يتم العثور على بيانات المستخدم'),
        );
      }

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Register Helper ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> registerHelper({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String aboutMe,
    required double hourlyRate,
    required List<String> specialties,
    required List<String> serviceAreas,
    required String idFrontPath,
    required String idBackPath,
    required String selfieWithIdPath,
  }) async {
    try {
      // 1. Create the Firebase Auth account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Upload verification documents to Firebase Storage
      final docUrls = await _remoteDataSource.uploadVerificationDocs(
        uid: uid,
        idFrontPath: idFrontPath,
        idBackPath: idBackPath,
        selfieWithIdPath: selfieWithIdPath,
      );

      // 3. Build the helper model with verification URLs (status = 'pending')
      final userModel = UserModel.newHelper(
        uid: uid,
        name: name,
        phone: phone,
        email: email,
        aboutMe: aboutMe,
        hourlyRate: hourlyRate,
        specialties: specialties,
        serviceAreas: serviceAreas,
        idFrontUrl: docUrls['idFrontUrl'],
        idBackUrl: docUrls['idBackUrl'],
        selfieUrl: docUrls['selfieUrl'],
      );

      // 4. Persist base user document to Firestore (includes URLs)
      await _remoteDataSource.createUserInFirestore(userModel);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Get Current User ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) return const Right(null);

      final userModel =
          await _remoteDataSource.getUserFromFirestore(firebaseUser.uid);

      return Right(userModel);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ── Upload Profile Image ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, String>> uploadProfileImage({
    required String uid,
    required String filePath,
  }) async {
    try {
      // 1. Upload the image to Firebase Storage
      final downloadUrl = await _remoteDataSource.uploadProfileImage(
        uid: uid,
        filePath: filePath,
      );

      // 2. Update the Firestore user document with the new URL
      await _remoteDataSource.updateUserFields(
        uid: uid,
        data: {'profileImageUrl': downloadUrl},
      );

      return Right(downloadUrl);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<UserEntity?> watchCurrentUser(String uid) {
    return _remoteDataSource.watchCurrentUser(uid);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(AuthFailure('المستخدم غير مسجل الدخول'));
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure('فشل تغيير كلمة المرور: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure('فشل إرسال البريد الإلكتروني: ${e.toString()}'));
    }
  }

  // ── Private: Map FirebaseAuth error codes → Arabic messages ───────────────
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً، استخدم 6 أحرف على الأقل';
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'user-disabled':
        return 'هذا الحساب موقوف، تواصل مع الدعم';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى الانتظار قليلاً';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ في المصادقة، حاول مرة أخرى';
    }
  }
}

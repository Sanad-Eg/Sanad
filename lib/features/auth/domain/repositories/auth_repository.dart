import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerClient({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String primaryNeedType,
  });

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
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, String>> uploadProfileImage({
    required String uid,
    required String filePath,
  });

  Stream<UserEntity?> watchCurrentUser(String uid);

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}

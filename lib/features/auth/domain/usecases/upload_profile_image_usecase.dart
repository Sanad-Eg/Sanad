import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';

class UploadProfileImageUseCase {
  final AuthRepository repository;
  UploadProfileImageUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String uid,
    required String filePath,
  }) {
    return repository.uploadProfileImage(uid: uid, filePath: filePath);
  }
}

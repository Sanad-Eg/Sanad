import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';

class RegisterClientUseCase {
  final AuthRepository repository;
  RegisterClientUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String primaryNeedType,
  }) {
    return repository.registerClient(
      name: name,
      phone: phone,
      email: email,
      password: password,
      primaryNeedType: primaryNeedType,
    );
  }
}

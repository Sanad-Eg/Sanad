import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository repository;

  GetUsersUseCase(this.repository);

  Stream<Either<Failure, List<UserEntity>>> call() {
    return repository.getUsersStream();
  }
}

import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';

class ApproveHelperUseCase {
  final AdminRepository _repository;

  ApproveHelperUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid) {
    return _repository.approveHelper(uid);
  }
}

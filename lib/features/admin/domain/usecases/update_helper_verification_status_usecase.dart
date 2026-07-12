import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';

class UpdateHelperVerificationStatusUseCase {
  final AdminRepository repository;

  UpdateHelperVerificationStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String helperId,
    required String status,
  }) async {
    return await repository.updateHelperVerificationStatus(
      helperId: helperId,
      status: status,
    );
  }
}

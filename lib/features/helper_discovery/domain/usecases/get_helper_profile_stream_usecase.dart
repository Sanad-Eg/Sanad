import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/domain/repositories/helper_repository.dart';

class GetHelperProfileStreamUseCase {
  final HelperRepository repository;

  GetHelperProfileStreamUseCase(this.repository);

  Stream<Either<Failure, HelperEntity>> call(String helperId) {
    return repository.getHelperProfileStream(helperId);
  }
}

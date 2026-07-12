import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/domain/repositories/helper_repository.dart';

class GetHelpersUseCase {
  final HelperRepository repository;

  GetHelpersUseCase(this.repository);

  Future<Either<Failure, List<HelperEntity>>> call({
    String? specialty,
    String? query,
  }) {
    return repository.getHelpers(
      specialty: specialty,
      query: query,
    );
  }
}

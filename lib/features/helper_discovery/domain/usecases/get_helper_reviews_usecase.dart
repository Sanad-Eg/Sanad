import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/helper_discovery/domain/entities/review_entity.dart';
import 'package:sanad/features/helper_discovery/domain/repositories/helper_repository.dart';

class GetHelperReviewsUseCase {
  final HelperRepository repository;

  GetHelperReviewsUseCase(this.repository);

  Stream<Either<Failure, List<ReviewEntity>>> call(String helperId) {
    return repository.getHelperReviews(helperId);
  }
}

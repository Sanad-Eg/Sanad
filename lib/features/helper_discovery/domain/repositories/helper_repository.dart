import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/domain/entities/review_entity.dart';

abstract class HelperRepository {
  Future<Either<Failure, List<HelperEntity>>> getHelpers({
    String? specialty,
    String? query,
  });

  Future<Either<Failure, HelperEntity>> getHelperProfile(String helperId);

  Stream<Either<Failure, HelperEntity>> getHelperProfileStream(String helperId);

  Stream<Either<Failure, List<ReviewEntity>>> getHelperReviews(String helperId);
}

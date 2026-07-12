import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/helper_discovery/data/datasources/helper_remote_data_source.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';
import 'package:sanad/features/helper_discovery/domain/entities/review_entity.dart';
import 'package:sanad/features/helper_discovery/domain/repositories/helper_repository.dart';

class FirebaseHelperRepositoryImpl implements HelperRepository {
  final HelperRemoteDataSource _remoteDataSource;

  FirebaseHelperRepositoryImpl({required HelperRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<HelperEntity>>> getHelpers({
    String? specialty,
    String? query,
  }) async {
    try {
      final helpers = await _remoteDataSource.getHelpers(
        specialty: specialty,
        query: query,
      );
      return Right(helpers);
    } on FirebaseException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, HelperEntity>> getHelperProfile(String helperId) async {
    try {
      final helper = await _remoteDataSource.getHelperProfile(helperId);
      return Right(helper);
    } on FirebaseException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, HelperEntity>> getHelperProfileStream(String helperId) {
    return _remoteDataSource.getHelperProfileStream(helperId).map<Either<Failure, HelperEntity>>(
      (helper) => Right(helper),
    ).handleError((error) {
      return const Left<Failure, HelperEntity>(ServerFailure());
    });
  }

  @override
  Stream<Either<Failure, List<ReviewEntity>>> getHelperReviews(String helperId) {
    return _remoteDataSource.getHelperReviews(helperId).map<Either<Failure, List<ReviewEntity>>>(
      (reviews) => Right(reviews),
    ).handleError((error) {
      return const Left<Failure, List<ReviewEntity>>(ServerFailure());
    });
  }
}

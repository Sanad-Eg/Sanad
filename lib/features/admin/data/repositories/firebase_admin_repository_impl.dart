import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';
import 'package:sanad/features/admin/data/datasources/admin_remote_data_source.dart';

class FirebaseAdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  FirebaseAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<UserEntity>>> getPendingHelpers() {
    return remoteDataSource.getPendingHelpers().map<Either<Failure, List<UserEntity>>>(
      (models) {
        return Right(models);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return const Left(ServerFailure());
      }
      return const Left(ServerFailure());
    });
  }

  @override
  Stream<Either<Failure, List<UserEntity>>> getUsersStream() {
    return remoteDataSource.getUsersStream().map<Either<Failure, List<UserEntity>>>(
      (models) {
        return Right(models);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return const Left(ServerFailure());
      }
      return const Left(ServerFailure());
    });
  }

  @override
  Stream<Either<Failure, List<BookingEntity>>> getAllBookingsStream() {
    return remoteDataSource.getAllBookingsStream().map<Either<Failure, List<BookingEntity>>>(
      (models) {
        return Right(models);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return const Left(ServerFailure());
      }
      return const Left(ServerFailure());
    });
  }

  @override
  Future<Either<Failure, void>> updateHelperVerificationStatus({
    required String helperId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateHelperVerificationStatus(
        helperId: helperId,
        status: status,
      );
      return const Right(null);
    } on FirebaseException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> approveHelper(String uid) async {
    try {
      await remoteDataSource.approveHelper(uid);
      return const Right(null);
    } on FirebaseException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

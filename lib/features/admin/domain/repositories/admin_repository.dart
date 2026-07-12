import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

abstract class AdminRepository {
  Stream<Either<Failure, List<UserEntity>>> getPendingHelpers();
  Stream<Either<Failure, List<UserEntity>>> getUsersStream();
  Stream<Either<Failure, List<BookingEntity>>> getAllBookingsStream();
  Future<Either<Failure, void>> updateHelperVerificationStatus({
    required String helperId,
    required String status,
  });
  Future<Either<Failure, void>> approveHelper(String uid);
}

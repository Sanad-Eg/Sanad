import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  final BookingRepository repository;

  GetMyBookingsUseCase(this.repository);

  Stream<Either<Failure, List<BookingEntity>>> call({
    required String userId,
    required String role,
    List<BookingStatus>? statuses,
  }) {
    return repository.getMyBookings(
      userId: userId,
      role: role,
      statuses: statuses,
    );
  }
}

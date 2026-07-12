import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class AcceptBookingUseCase {
  final BookingRepository repository;

  AcceptBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(String bookingId, double agreedPrice) {
    return repository.acceptBooking(bookingId, agreedPrice);
  }
}

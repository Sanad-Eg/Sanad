import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class GetBookingStreamUseCase {
  final BookingRepository repository;

  GetBookingStreamUseCase(this.repository);

  Stream<Either<Failure, BookingEntity>> call(String bookingId) {
    return repository.getBookingStream(bookingId);
  }
}

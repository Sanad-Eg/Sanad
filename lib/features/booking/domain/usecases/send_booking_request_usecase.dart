import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class SendBookingRequestUseCase {
  final BookingRepository repository;

  SendBookingRequestUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(BookingEntity booking) {
    return repository.sendBookingRequest(booking);
  }
}

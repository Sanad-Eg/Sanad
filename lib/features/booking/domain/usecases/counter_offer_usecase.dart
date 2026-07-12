import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class CounterOfferUseCase {
  final BookingRepository repository;

  CounterOfferUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required String bookingId,
    required double newPrice,
    required String note,
  }) {
    return repository.counterOffer(
      bookingId: bookingId,
      newPrice: newPrice,
      note: note,
    );
  }
}

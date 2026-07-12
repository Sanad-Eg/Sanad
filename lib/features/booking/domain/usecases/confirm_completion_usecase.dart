import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class ConfirmCompletionUseCase {
  final BookingRepository repository;

  ConfirmCompletionUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required String bookingId,
    required bool isClient,
  }) {
    return repository.confirmCompletion(
      bookingId: bookingId,
      isClient: isClient,
    );
  }
}

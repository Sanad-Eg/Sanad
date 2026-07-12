import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

class SubmitReviewUseCase {
  final BookingRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  }) {
    return repository.submitReview(
      bookingId: bookingId,
      helperId: helperId,
      clientId: clientId,
      rating: rating,
      reviewText: reviewText,
    );
  }
}

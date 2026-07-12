import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> sendBookingRequest(BookingEntity booking);

  Future<Either<Failure, BookingEntity>> acceptBooking(String bookingId, double agreedPrice);

  Future<Either<Failure, BookingEntity>> rejectBooking(String bookingId);

  Future<Either<Failure, BookingEntity>> counterOffer({
    required String bookingId,
    required double newPrice,
    required String note,
  });

  Future<Either<Failure, BookingEntity>> payBooking(String bookingId);

  Future<Either<Failure, BookingEntity>> confirmCompletion({
    required String bookingId,
    required bool isClient,
  });

  Stream<Either<Failure, BookingEntity>> getBookingStream(String bookingId);

  Stream<Either<Failure, BookingEntity>> trackBooking(String bookingId);

  Stream<Either<Failure, List<BookingEntity>>> getMyBookings({
    required String userId,
    required String role,
    List<BookingStatus>? statuses,
  });

  Stream<Either<Failure, List<BookingEntity>>> getClientBookingsStream(String clientId);

  Stream<Either<Failure, List<BookingEntity>>> getHelperBookingsStream(String helperId);

  Future<Either<Failure, Unit>> submitReview({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  });
}

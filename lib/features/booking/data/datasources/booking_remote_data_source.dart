import 'package:sanad/features/booking/data/models/booking_model.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

/// Contract for all remote Firestore operations on the `bookings` collection.
/// The Domain layer never sees this — only [FirebaseBookingRepositoryImpl] uses it.
abstract class BookingRemoteDataSource {
  /// Creates a new booking document in Firestore.
  /// Returns the saved [BookingModel] with its auto-generated document ID.
  Future<BookingModel> createBooking(BookingModel booking);

  /// Updates only the [status] field of a booking document.
  /// Returns the updated [BookingModel].
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  });

  /// Atomically updates [status], [agreedHourlyRate], [agreedPrice], [totalAmount],
  /// and [confirmedAt] when a booking is accepted.
  Future<BookingModel> acceptBooking(String bookingId, double agreedPrice);

  /// Updates [status] to `cancelled` when the helper rejects a request.
  Future<BookingModel> rejectBooking(String bookingId);

  /// Updates [status] to `negotiating`, increments [negotiationRound],
  /// stores the helper's [newPrice] as [agreedHourlyRate], and saves [note].
  Future<BookingModel> counterOffer({
    required String bookingId,
    required double newPrice,
    required String note,
  });

  /// Marks the booking as paid by setting [paidAt] and [status] to `inProgress`.
  Future<BookingModel> payBooking(String bookingId);

  /// Records a dual-confirmation:
  ///   - Sets [clientConfirmed] if [isClient] is true.
  ///   - Sets [helperConfirmed] if [isClient] is false.
  ///   - When both are true, sets [status] to `completed`.
  Future<BookingModel> confirmCompletion({
    required String bookingId,
    required bool isClient,
  });

  /// Returns a real-time [Stream] of [BookingModel] for the given [bookingId].
  /// Powered by Firestore `.snapshots()` — the Cubit listens to this for
  /// live state machine updates without polling.
  Stream<BookingModel> getBookingStream(String bookingId);

  /// Powered by Firestore `.snapshots()` - returns a real-time stream of BookingEntity.
  Stream<BookingEntity> trackBooking(String bookingId);

  /// Returns a stream of list of [BookingModel] for a given user (filtered by role).
  Stream<List<BookingModel>> getMyBookings({
    required String userId,
    required String role,
    List<BookingStatus>? statuses,
  });

  Stream<List<BookingModel>> getClientBookingsStream(String clientId);

  Stream<List<BookingModel>> getHelperBookingsStream(String helperId);

  Future<void> submitReview({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  });
}

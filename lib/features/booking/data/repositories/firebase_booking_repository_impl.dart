import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sanad/features/booking/data/models/booking_model.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';

/// Firebase implementation of [BookingRepository].
///
/// Responsibilities:
///   - Translates domain [BookingEntity] objects into [BookingModel] for the DataSource.
///   - Delegates all Firestore I/O to [BookingRemoteDataSource].
///   - Wraps all exceptions into typed [Failure] subtypes (Left).
///   - Returns domain [BookingEntity] objects upward (Right) — no Data types leak.
class FirebaseBookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  FirebaseBookingRepositoryImpl({
    required BookingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ── Private: cast entity → model for the data source ─────────────────────
  BookingModel _toModel(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      clientId: entity.clientId,
      helperId: entity.helperId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      durationHours: entity.durationHours,
      latitude: entity.latitude,
      longitude: entity.longitude,
      locationAddress: entity.locationAddress,
      taskDescription: entity.taskDescription,
      proposedHourlyRate: entity.proposedHourlyRate,
      agreedHourlyRate: entity.agreedHourlyRate,
      agreedPrice: entity.agreedPrice,
      totalAmount: entity.totalAmount,
      status: entity.status,
      negotiationRound: entity.negotiationRound,
      helperNote: entity.helperNote,
      createdAt: entity.createdAt,
      confirmedAt: entity.confirmedAt,
      paidAt: entity.paidAt,
      completionRequestedAt: entity.completionRequestedAt,
      clientConfirmed: entity.clientConfirmed,
      helperConfirmed: entity.helperConfirmed,
    );
  }

  // ── Send Booking Request ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> sendBookingRequest(
    BookingEntity booking,
  ) async {
    try {
      final model = await _remoteDataSource.createBooking(_toModel(booking));
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في إرسال طلب الحجز'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Accept ────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> acceptBooking(
    String bookingId,
    double agreedPrice,
  ) async {
    try {
      final model = await _remoteDataSource.acceptBooking(bookingId, agreedPrice);
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في قبول الحجز'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Reject ────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> rejectBooking(
    String bookingId,
  ) async {
    try {
      final model = await _remoteDataSource.rejectBooking(bookingId);
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في رفض الحجز'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Counter Offer ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> counterOffer({
    required String bookingId,
    required double newPrice,
    required String note,
  }) async {
    try {
      final model = await _remoteDataSource.counterOffer(
        bookingId: bookingId,
        newPrice: newPrice,
        note: note,
      );
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في تقديم عرض بديل'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Pay (Escrow Lock) ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> payBooking(String bookingId) async {
    try {
      final model = await _remoteDataSource.payBooking(bookingId);
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في تنفيذ الدفع'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Dual Completion Confirmation ──────────────────────────────────────────
  @override
  Future<Either<Failure, BookingEntity>> confirmCompletion({
    required String bookingId,
    required bool isClient,
  }) async {
    try {
      final model = await _remoteDataSource.confirmCompletion(
        bookingId: bookingId,
        isClient: isClient,
      );
      return Right(model);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في تأكيد اكتمال الخدمة'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }

  // ── Real-time Stream ──────────────────────────────────────────────────────
  /// Maps the DataSource stream of [BookingModel] to [Either<Failure, BookingEntity>].
  /// Any exception from the stream is caught per-event and wrapped as [BookingFailure].
  @override
  Stream<Either<Failure, BookingEntity>> getBookingStream(String bookingId) {
    return _remoteDataSource.getBookingStream(bookingId).map<Either<Failure, BookingEntity>>(
      (model) => Right(model),
    ).handleError(
      (error) => Left<Failure, BookingEntity>(
        error is FirebaseException
            ? BookingFailure(error.message ?? 'خطأ في تحديثات الحجز')
            : BookingFailure(error.toString()),
      ),
    );
  }

  @override
  Stream<Either<Failure, BookingEntity>> trackBooking(String bookingId) {
    return _remoteDataSource.trackBooking(bookingId).map<Either<Failure, BookingEntity>>(
      (model) => Right(model),
    ).handleError(
      (error) => Left<Failure, BookingEntity>(
        error is FirebaseException
            ? BookingFailure(error.message ?? 'خطأ في تحديثات الحجز')
            : BookingFailure(error.toString()),
      ),
    );
  }

  @override
  Stream<Either<Failure, List<BookingEntity>>> getMyBookings({
    required String userId,
    required String role,
    List<BookingStatus>? statuses,
  }) {
    return _remoteDataSource
        .getMyBookings(userId: userId, role: role, statuses: statuses)
        .map<Either<Failure, List<BookingEntity>>>(
          (list) => Right(list),
        )
        .handleError(
          (error) => Left<Failure, List<BookingEntity>>(
            error is FirebaseException
                ? BookingFailure(error.message ?? 'خطأ في جلب قائمة الحجوزات')
                : BookingFailure(error.toString()),
          ),
        );
  }

  @override
  Stream<Either<Failure, List<BookingEntity>>> getClientBookingsStream(String clientId) {
    return _remoteDataSource
        .getClientBookingsStream(clientId)
        .map<Either<Failure, List<BookingEntity>>>(
          (list) => Right(list),
        )
        .handleError(
          (error) => Left<Failure, List<BookingEntity>>(
            error is FirebaseException
                ? BookingFailure(error.message ?? 'خطأ في جلب قائمة الحجوزات')
                : BookingFailure(error.toString()),
          ),
        );
  }

  @override
  Stream<Either<Failure, List<BookingEntity>>> getHelperBookingsStream(String helperId) {
    return _remoteDataSource
        .getHelperBookingsStream(helperId)
        .map<Either<Failure, List<BookingEntity>>>(
          (list) => Right(list),
        )
        .handleError(
          (error) => Left<Failure, List<BookingEntity>>(
            error is FirebaseException
                ? BookingFailure(error.message ?? 'خطأ في جلب قائمة حجوزات المساعد')
                : BookingFailure(error.toString()),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> submitReview({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  }) async {
    try {
      await _remoteDataSource.submitReview(
        bookingId: bookingId,
        helperId: helperId,
        clientId: clientId,
        rating: rating,
        reviewText: reviewText,
      );
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(BookingFailure(e.message ?? 'خطأ في إرسال التقييم'));
    } catch (e) {
      return Left(BookingFailure(e.toString()));
    }
  }
}

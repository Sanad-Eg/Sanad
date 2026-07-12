import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/usecases/accept_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/confirm_completion_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/counter_offer_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/pay_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/reject_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/send_booking_request_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_state.dart';
import 'package:sanad/features/booking/domain/usecases/track_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/submit_review_usecase.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class BookingCubit extends Cubit<BookingState> {
  final SendBookingRequestUseCase _sendBookingRequest;
  final AcceptBookingUseCase _acceptBooking;
  final RejectBookingUseCase _rejectBooking;
  final CounterOfferUseCase _counterOffer;
  final PayBookingUseCase _payBooking;
  final ConfirmCompletionUseCase _confirmCompletion;
  final TrackBookingUseCase _trackBooking;
  final SubmitReviewUseCase _submitReview;

  StreamSubscription? _bookingStreamSubscription;
  StreamSubscription<Either<Failure, BookingEntity>>? _bookingSubscription;

  BookingCubit({
    required SendBookingRequestUseCase sendBookingRequest,
    required AcceptBookingUseCase acceptBooking,
    required RejectBookingUseCase rejectBooking,
    required CounterOfferUseCase counterOffer,
    required PayBookingUseCase payBooking,
    required ConfirmCompletionUseCase confirmCompletion,
    required TrackBookingUseCase trackBooking,
    required SubmitReviewUseCase submitReview,
  })  : _sendBookingRequest = sendBookingRequest,
        _acceptBooking = acceptBooking,
        _rejectBooking = rejectBooking,
        _counterOffer = counterOffer,
        _payBooking = payBooking,
        _confirmCompletion = confirmCompletion,
        _trackBooking = trackBooking,
        _submitReview = submitReview,
        super(const BookingState());

  // ── Stream Subscription ──────────────────────────────────────────────────
  void watchBooking(String bookingId) {
    startTracking(bookingId);
  }

  void startTracking(String bookingId) {
    _bookingSubscription?.cancel();
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));

    _bookingSubscription = _trackBooking(bookingId).listen(
      (result) {
        result.fold(
          (failure) {
            emit(state.copyWith(
              status: BookingCubitStatus.error,
              errorMessage: () => failure.message,
            ));
          },
          (booking) {
            emit(state.copyWith(
              status: BookingCubitStatus.loaded,
              booking: booking,
              errorMessage: () => null,
            ));
          },
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: BookingCubitStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  // ── Send Booking Request ──────────────────────────────────────────────────
  Future<void> sendRequest(BookingEntity booking) async {
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _sendBookingRequest(booking);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (newBooking) {
        emit(state.copyWith(
          status: BookingCubitStatus.loaded,
          booking: newBooking,
        ));
        // Start watching the newly created booking in real-time
        watchBooking(newBooking.id);
      },
    );
  }

  // ── Accept Booking ────────────────────────────────────────────────────────
  Future<void> accept(String bookingId, double? agreedPrice) async {
    if (agreedPrice == null || agreedPrice <= 0) {
      emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => "لا يمكن قبول أو بدء الطلب بدون تحديد السعر النهائي.",
      ));
      return;
    }
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _acceptBooking(bookingId, agreedPrice);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (updatedBooking) => emit(state.copyWith(
        status: BookingCubitStatus.loaded,
        booking: updatedBooking,
      )),
    );
  }

  // ── Reject Booking ────────────────────────────────────────────────────────
  Future<void> reject(String bookingId) async {
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _rejectBooking(bookingId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (updatedBooking) => emit(state.copyWith(
        status: BookingCubitStatus.loaded,
        booking: updatedBooking,
      )),
    );
  }

  // ── Counter Offer ─────────────────────────────────────────────────────────
  Future<void> submitCounterOffer({
    required String bookingId,
    required double newPrice,
    required String note,
  }) async {
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _counterOffer(
      bookingId: bookingId,
      newPrice: newPrice,
      note: note,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (updatedBooking) => emit(state.copyWith(
        status: BookingCubitStatus.loaded,
        booking: updatedBooking,
      )),
    );
  }

  // ── Pay (Escrow) ──────────────────────────────────────────────────────────
  Future<void> pay(String bookingId) async {
    final booking = state.booking;
    final agreedPrice = booking?.agreedPrice ?? booking?.agreedHourlyRate;
    if (agreedPrice == null || agreedPrice <= 0) {
      emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => "لا يمكن قبول أو بدء الطلب بدون تحديد السعر النهائي.",
      ));
      return;
    }
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _payBooking(bookingId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (updatedBooking) => emit(state.copyWith(
        status: BookingCubitStatus.loaded,
        booking: updatedBooking,
      )),
    );
  }

  // ── Confirm Completion ───────────────────────────────────────────────────
  Future<void> confirm(String bookingId, {required bool isClient}) async {
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _confirmCompletion(
      bookingId: bookingId,
      isClient: isClient,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: BookingCubitStatus.error,
          errorMessage: () => failure.message,
        ));
      },
      (updatedBooking) {
        emit(state.copyWith(
          status: BookingCubitStatus.loaded,
          booking: updatedBooking,
        ));
      },
    );
  }

  Future<void> submitRatingAndReview({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  }) async {
    emit(state.copyWith(status: BookingCubitStatus.loading, errorMessage: () => null));
    final result = await _submitReview(
      bookingId: bookingId,
      helperId: helperId,
      clientId: clientId,
      rating: rating,
      reviewText: reviewText,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingCubitStatus.error,
        errorMessage: () => failure.message,
      )),
      (_) => emit(state.copyWith(
        status: BookingCubitStatus.loaded,
      )),
    );
  }

  // ── Clear Error ───────────────────────────────────────────────────────────
  void clearError() {
    emit(state.copyWith(errorMessage: () => null));
  }

  @override
  Future<void> close() {
    _bookingStreamSubscription?.cancel();
    _bookingSubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

enum BookingCubitStatus { initial, loading, loaded, error }

class BookingState extends Equatable {
  final BookingCubitStatus status;
  final BookingEntity? booking;
  final String? errorMessage;

  const BookingState({
    this.status = BookingCubitStatus.initial,
    this.booking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingCubitStatus? status,
    BookingEntity? booking,
    String? Function()? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, booking, errorMessage];
}

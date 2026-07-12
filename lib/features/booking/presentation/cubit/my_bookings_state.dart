import 'package:equatable/equatable.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

enum MyBookingsStatus { initial, loading, loaded, error }

class MyBookingsState extends Equatable {
  final MyBookingsStatus status;
  final List<BookingEntity> bookings;
  final String? errorMessage;

  const MyBookingsState({
    this.status = MyBookingsStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  MyBookingsState copyWith({
    MyBookingsStatus? status,
    List<BookingEntity>? bookings,
    String? Function()? errorMessage,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}

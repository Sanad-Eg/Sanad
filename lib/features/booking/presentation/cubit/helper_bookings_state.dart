import 'package:equatable/equatable.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

abstract class HelperBookingsState extends Equatable {
  const HelperBookingsState();

  @override
  List<Object?> get props => [];
}

class HelperBookingsInitial extends HelperBookingsState {}

class HelperBookingsLoading extends HelperBookingsState {}

class HelperBookingsLoaded extends HelperBookingsState {
  final List<BookingEntity> bookings;

  const HelperBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class HelperBookingsError extends HelperBookingsState {
  final String message;

  const HelperBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

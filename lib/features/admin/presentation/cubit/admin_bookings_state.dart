import 'package:equatable/equatable.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

abstract class AdminBookingsState extends Equatable {
  const AdminBookingsState();

  @override
  List<Object?> get props => [];
}

class AdminBookingsInitial extends AdminBookingsState {
  const AdminBookingsInitial();
}

class AdminBookingsLoading extends AdminBookingsState {
  const AdminBookingsLoading();
}

class AdminBookingsLoaded extends AdminBookingsState {
  final List<BookingEntity> bookings;

  const AdminBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class AdminBookingsError extends AdminBookingsState {
  final String message;

  const AdminBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

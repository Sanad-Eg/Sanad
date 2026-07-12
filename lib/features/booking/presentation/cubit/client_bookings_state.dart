import 'package:equatable/equatable.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

abstract class ClientBookingsState extends Equatable {
  const ClientBookingsState();

  @override
  List<Object?> get props => [];
}

class ClientBookingsInitial extends ClientBookingsState {}

class ClientBookingsLoading extends ClientBookingsState {}

class ClientBookingsLoaded extends ClientBookingsState {
  final List<BookingEntity> bookings;

  const ClientBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class ClientBookingsError extends ClientBookingsState {
  final String message;

  const ClientBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

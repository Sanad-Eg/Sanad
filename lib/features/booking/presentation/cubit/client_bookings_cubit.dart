import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/usecases/get_client_bookings_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/client_bookings_state.dart';

class ClientBookingsCubit extends Cubit<ClientBookingsState> {
  final GetClientBookingsUseCase _getClientBookings;
  StreamSubscription<Either<Failure, List<BookingEntity>>>? _bookingsSubscription;

  ClientBookingsCubit({
    required GetClientBookingsUseCase getClientBookings,
  })  : _getClientBookings = getClientBookings,
        super(ClientBookingsInitial());

  void watchClientBookings(String clientId) {
    _bookingsSubscription?.cancel();
    emit(ClientBookingsLoading());

    _bookingsSubscription = _getClientBookings(clientId).listen(
      (result) {
        result.fold(
          (failure) => emit(ClientBookingsError(failure.message)),
          (bookings) => emit(ClientBookingsLoaded(bookings)),
        );
      },
      onError: (error) {
        emit(ClientBookingsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}

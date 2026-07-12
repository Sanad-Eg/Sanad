import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/usecases/get_helper_bookings_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/helper_bookings_state.dart';

class HelperBookingsCubit extends Cubit<HelperBookingsState> {
  final GetHelperBookingsUseCase _getHelperBookings;
  StreamSubscription<Either<Failure, List<BookingEntity>>>? _bookingsSubscription;

  HelperBookingsCubit({
    required GetHelperBookingsUseCase getHelperBookings,
  })  : _getHelperBookings = getHelperBookings,
        super(HelperBookingsInitial());

  void watchHelperBookings(String helperId) {
    _bookingsSubscription?.cancel();
    emit(HelperBookingsLoading());

    _bookingsSubscription = _getHelperBookings(helperId).listen(
      (result) {
        result.fold(
          (failure) => emit(HelperBookingsError(failure.message)),
          (bookings) => emit(HelperBookingsLoaded(bookings)),
        );
      },
      onError: (error) {
        emit(HelperBookingsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}

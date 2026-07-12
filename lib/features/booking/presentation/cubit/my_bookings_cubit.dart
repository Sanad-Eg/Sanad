import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase _getMyBookings;
  StreamSubscription? _bookingsSubscription;

  MyBookingsCubit({
    required GetMyBookingsUseCase getMyBookings,
  })  : _getMyBookings = getMyBookings,
        super(const MyBookingsState());

  /// Listens to real-time updates for user's bookings.
  void watchMyBookings(String userId, String role, {List<BookingStatus>? statuses}) {
    _bookingsSubscription?.cancel();
    emit(state.copyWith(status: MyBookingsStatus.loading, errorMessage: () => null));

    _bookingsSubscription = _getMyBookings(
      userId: userId,
      role: role,
      statuses: statuses,
    ).listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: MyBookingsStatus.error,
            errorMessage: () => failure.message,
          )),
          (bookings) => emit(state.copyWith(
            status: MyBookingsStatus.loaded,
            bookings: bookings,
            errorMessage: () => null,
          )),
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: MyBookingsStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}

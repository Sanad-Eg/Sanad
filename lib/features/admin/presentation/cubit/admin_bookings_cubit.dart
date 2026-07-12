import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/admin/domain/usecases/get_all_bookings_usecase.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_bookings_state.dart';

class AdminBookingsCubit extends Cubit<AdminBookingsState> {
  final GetAllBookingsUseCase _getAllBookings;
  StreamSubscription? _bookingsSubscription;

  AdminBookingsCubit({required GetAllBookingsUseCase getAllBookings})
      : _getAllBookings = getAllBookings,
        super(const AdminBookingsInitial());

  void watchAllBookings() {
    emit(const AdminBookingsLoading());
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _getAllBookings().listen(
      (result) {
        result.fold(
          (failure) => emit(AdminBookingsError(failure.message)),
          (bookings) => emit(AdminBookingsLoaded(bookings)),
        );
      },
      onError: (error) {
        emit(AdminBookingsError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}

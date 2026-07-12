import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_profile_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helpers_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_profile_stream_usecase.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_state.dart';

class HelperDiscoveryCubit extends Cubit<HelperDiscoveryState> {
  final GetHelpersUseCase _getHelpers;
  final GetHelperProfileUseCase _getHelperProfile;
  final GetHelperProfileStreamUseCase _getHelperProfileStream;
  StreamSubscription? _helperProfileSubscription;

  HelperDiscoveryCubit({
    required GetHelpersUseCase getHelpers,
    required GetHelperProfileUseCase getHelperProfile,
    required GetHelperProfileStreamUseCase getHelperProfileStream,
  })  : _getHelpers = getHelpers,
        _getHelperProfile = getHelperProfile,
        _getHelperProfileStream = getHelperProfileStream,
        super(const HelperDiscoveryState());

  Future<void> fetchHelpers({
    String? specialty,
    String? query,
  }) async {
    final activeSpecialty = specialty ?? state.currentSpecialty;
    final activeQuery = query ?? state.searchQuery;

    emit(state.copyWith(
      status: HelperDiscoveryStatus.loading,
      currentSpecialty: activeSpecialty,
      searchQuery: activeQuery,
      errorMessage: () => null,
    ));

    final result = await _getHelpers(
      specialty: activeSpecialty,
      query: activeQuery,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: HelperDiscoveryStatus.error,
        errorMessage: () => failure.message,
      )),
      (helpers) => emit(state.copyWith(
        status: HelperDiscoveryStatus.loaded,
        helpers: helpers,
      )),
    );
  }

  Future<void> fetchHelperProfile(String helperId) async {
    emit(state.copyWith(
      status: HelperDiscoveryStatus.loading,
      selectedHelper: () => null,
      errorMessage: () => null,
    ));

    final result = await _getHelperProfile(helperId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: HelperDiscoveryStatus.error,
        errorMessage: () => failure.message,
      )),
      (helper) => emit(state.copyWith(
        status: HelperDiscoveryStatus.loaded,
        selectedHelper: () => helper,
      )),
    );
  }

  void watchHelperProfile(String helperId) {
    _helperProfileSubscription?.cancel();
    emit(state.copyWith(
      status: HelperDiscoveryStatus.loading,
      selectedHelper: () => null,
      errorMessage: () => null,
    ));

    _helperProfileSubscription = _getHelperProfileStream(helperId).listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(
          status: HelperDiscoveryStatus.error,
          errorMessage: () => failure.message,
        )),
        (helper) => emit(state.copyWith(
          status: HelperDiscoveryStatus.loaded,
          selectedHelper: () => helper,
        )),
      );
    });
  }

  void resetDiscovery() {
    emit(const HelperDiscoveryState());
  }

  @override
  Future<void> close() {
    _helperProfileSubscription?.cancel();
    return super.close();
  }
}

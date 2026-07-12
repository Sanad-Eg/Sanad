import 'package:equatable/equatable.dart';
import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';

enum HelperDiscoveryStatus { initial, loading, loaded, error }

class HelperDiscoveryState extends Equatable {
  final HelperDiscoveryStatus status;
  final List<HelperEntity> helpers;
  final HelperEntity? selectedHelper;
  final String? errorMessage;
  final String currentSpecialty;
  final String searchQuery;

  const HelperDiscoveryState({
    this.status = HelperDiscoveryStatus.initial,
    this.helpers = const [],
    this.selectedHelper,
    this.errorMessage,
    this.currentSpecialty = 'all',
    this.searchQuery = '',
  });

  HelperDiscoveryState copyWith({
    HelperDiscoveryStatus? status,
    List<HelperEntity>? helpers,
    HelperEntity? Function()? selectedHelper,
    String? Function()? errorMessage,
    String? currentSpecialty,
    String? searchQuery,
  }) {
    return HelperDiscoveryState(
      status: status ?? this.status,
      helpers: helpers ?? this.helpers,
      selectedHelper: selectedHelper != null ? selectedHelper() : this.selectedHelper,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      currentSpecialty: currentSpecialty ?? this.currentSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        helpers,
        selectedHelper,
        errorMessage,
        currentSpecialty,
        searchQuery,
      ];
}

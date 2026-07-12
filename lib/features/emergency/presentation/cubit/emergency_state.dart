import 'package:equatable/equatable.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';

enum EmergencyStatus { initial, loading, success, error }

class EmergencyState extends Equatable {
  final EmergencyStatus status;
  final List<EmergencyContactEntity> contacts;
  final String? errorMessage;
  final bool isSubmitting;

  const EmergencyState({
    this.status = EmergencyStatus.initial,
    this.contacts = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  EmergencyState copyWith({
    EmergencyStatus? status,
    List<EmergencyContactEntity>? contacts,
    String? Function()? errorMessage,
    bool? isSubmitting,
  }) {
    return EmergencyState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, contacts, errorMessage, isSubmitting];
}

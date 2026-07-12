import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:sanad/features/emergency/domain/usecases/add_emergency_contact_usecase.dart';
import 'package:sanad/features/emergency/domain/usecases/get_emergency_contacts_usecase.dart';
import 'package:sanad/features/emergency/domain/usecases/remove_emergency_contact_usecase.dart';
import 'package:sanad/features/emergency/presentation/cubit/emergency_state.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  final GetEmergencyContactsUseCase _getEmergencyContacts;
  final AddEmergencyContactUseCase _addEmergencyContact;
  final RemoveEmergencyContactUseCase _removeEmergencyContact;

  StreamSubscription? _contactsSubscription;

  EmergencyCubit({
    required GetEmergencyContactsUseCase getEmergencyContacts,
    required AddEmergencyContactUseCase addEmergencyContact,
    required RemoveEmergencyContactUseCase removeEmergencyContact,
  })  : _getEmergencyContacts = getEmergencyContacts,
        _addEmergencyContact = addEmergencyContact,
        _removeEmergencyContact = removeEmergencyContact,
        super(const EmergencyState());

  void watchContacts(String clientId) {
    _contactsSubscription?.cancel();
    emit(state.copyWith(status: EmergencyStatus.loading, errorMessage: () => null));

    _contactsSubscription = _getEmergencyContacts(clientId).listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: EmergencyStatus.error,
            errorMessage: () => failure.message,
          )),
          (contacts) => emit(state.copyWith(
            status: EmergencyStatus.success,
            contacts: contacts,
            errorMessage: () => null,
          )),
        );
      },
      onError: (error) {
        emit(state.copyWith(
          status: EmergencyStatus.error,
          errorMessage: () => error.toString(),
        ));
      },
    );
  }

  Future<void> addContact({
    required String clientId,
    required String name,
    required String phoneNumber,
    required String relation,
  }) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: () => null));
    final contact = EmergencyContactEntity(
      id: '', // Will be generated in datasource
      clientId: clientId,
      name: name,
      phoneNumber: phoneNumber,
      relation: relation,
    );

    final result = await _addEmergencyContact(contact);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          status: EmergencyStatus.error,
          errorMessage: () => failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isSubmitting: false));
      },
    );
  }

  Future<void> removeContact(String contactId, String clientId) async {
    emit(state.copyWith(status: EmergencyStatus.loading, errorMessage: () => null));
    final result = await _removeEmergencyContact(contactId: contactId, clientId: clientId);
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: EmergencyStatus.error,
          errorMessage: () => failure.message,
        ));
      },
      (_) => null, // Let stream update dynamically
    );
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}

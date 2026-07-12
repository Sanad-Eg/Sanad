import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:sanad/features/emergency/domain/repositories/emergency_repository.dart';

class AddEmergencyContactUseCase {
  final EmergencyRepository repository;

  AddEmergencyContactUseCase(this.repository);

  Future<Either<Failure, void>> call(EmergencyContactEntity contact) async {
    return await repository.addEmergencyContact(contact);
  }
}

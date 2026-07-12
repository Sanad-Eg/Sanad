import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:sanad/features/emergency/domain/repositories/emergency_repository.dart';

class GetEmergencyContactsUseCase {
  final EmergencyRepository repository;

  GetEmergencyContactsUseCase(this.repository);

  Stream<Either<Failure, List<EmergencyContactEntity>>> call(String clientId) {
    return repository.getEmergencyContacts(clientId);
  }
}

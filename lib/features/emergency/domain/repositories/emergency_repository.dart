import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';

abstract class EmergencyRepository {
  Future<Either<Failure, void>> addEmergencyContact(EmergencyContactEntity contact);
  Future<Either<Failure, void>> removeEmergencyContact(String contactId, String clientId);
  Stream<Either<Failure, List<EmergencyContactEntity>>> getEmergencyContacts(String clientId);
}

import 'package:dartz/dartz.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/emergency/domain/repositories/emergency_repository.dart';

class RemoveEmergencyContactUseCase {
  final EmergencyRepository repository;

  RemoveEmergencyContactUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String contactId,
    required String clientId,
  }) async {
    return await repository.removeEmergencyContact(contactId, clientId);
  }
}

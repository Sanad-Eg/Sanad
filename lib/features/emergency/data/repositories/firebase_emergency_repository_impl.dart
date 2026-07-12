import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/features/emergency/data/datasources/emergency_remote_data_source.dart';
import 'package:sanad/features/emergency/data/models/emergency_contact_model.dart';
import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:sanad/features/emergency/domain/repositories/emergency_repository.dart';

class FirebaseEmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource remoteDataSource;

  FirebaseEmergencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addEmergencyContact(EmergencyContactEntity contact) async {
    try {
      final model = EmergencyContactModel(
        id: contact.id,
        clientId: contact.clientId,
        name: contact.name,
        phoneNumber: contact.phoneNumber,
        relation: contact.relation,
      );
      await remoteDataSource.addEmergencyContact(model);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(EmergencyFailure(e.message ?? 'حدث خطأ أثناء إضافة جهة اتصال الطوارئ'));
    } catch (e) {
      return Left(EmergencyFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeEmergencyContact(String contactId, String clientId) async {
    try {
      await remoteDataSource.removeEmergencyContact(contactId, clientId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(EmergencyFailure(e.message ?? 'حدث خطأ أثناء حذف جهة اتصال الطوارئ'));
    } catch (e) {
      return Left(EmergencyFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<EmergencyContactEntity>>> getEmergencyContacts(String clientId) {
    return remoteDataSource.getEmergencyContacts(clientId).map<Either<Failure, List<EmergencyContactEntity>>>(
      (models) {
        return Right(models);
      },
    ).handleError((error) {
      if (error is FirebaseException) {
        return Left(EmergencyFailure(error.message ?? 'حدث خطأ أثناء جلب جهات اتصال الطوارئ'));
      }
      return Left(EmergencyFailure(error.toString()));
    });
  }
}

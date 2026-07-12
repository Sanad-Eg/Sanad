import 'package:sanad/features/emergency/data/models/emergency_contact_model.dart';

abstract class EmergencyRemoteDataSource {
  Future<void> addEmergencyContact(EmergencyContactModel contact);
  Future<void> removeEmergencyContact(String contactId, String clientId);
  Stream<List<EmergencyContactModel>> getEmergencyContacts(String clientId);
}

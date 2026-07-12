import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/emergency/data/datasources/emergency_remote_data_source.dart';
import 'package:sanad/features/emergency/data/models/emergency_contact_model.dart';

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final FirebaseFirestore _firestore;

  EmergencyRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _contactsCollection(String clientId) =>
      _firestore.collection('users').doc(clientId).collection('emergency_contacts');

  @override
  Future<void> addEmergencyContact(EmergencyContactModel contact) async {
    final col = _contactsCollection(contact.clientId);
    // If contact.id is empty, auto-generate a document ID, otherwise use existing one.
    final docRef = contact.id.isEmpty ? col.doc() : col.doc(contact.id);
    final modelWithId = contact.id.isEmpty
        ? EmergencyContactModel(
            id: docRef.id,
            clientId: contact.clientId,
            name: contact.name,
            phoneNumber: contact.phoneNumber,
            relation: contact.relation,
          )
        : contact;

    await docRef.set(modelWithId.toJson());
  }

  @override
  Future<void> removeEmergencyContact(String contactId, String clientId) async {
    await _contactsCollection(clientId).doc(contactId).delete();
  }

  @override
  Stream<List<EmergencyContactModel>> getEmergencyContacts(String clientId) {
    return _contactsCollection(clientId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmergencyContactModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}

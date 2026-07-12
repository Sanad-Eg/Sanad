import 'package:sanad/features/emergency/domain/entities/emergency_contact_entity.dart';

class EmergencyContactModel extends EmergencyContactEntity {
  const EmergencyContactModel({
    required super.id,
    required super.clientId,
    required super.name,
    required super.phoneNumber,
    required super.relation,
  });

  factory EmergencyContactModel.fromFirestore(Map<String, dynamic> json, String id) {
    return EmergencyContactModel(
      id: id,
      clientId: json['clientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'name': name,
      'phoneNumber': phoneNumber,
      'relation': relation,
    };
  }
}

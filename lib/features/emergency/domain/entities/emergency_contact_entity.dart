import 'package:equatable/equatable.dart';

class EmergencyContactEntity extends Equatable {
  final String id;
  final String clientId;
  final String name;
  final String phoneNumber;
  final String relation; // e.g. 'Son', 'Daughter', 'Friend'

  const EmergencyContactEntity({
    required this.id,
    required this.clientId,
    required this.name,
    required this.phoneNumber,
    required this.relation,
  });

  @override
  List<Object?> get props => [id, clientId, name, phoneNumber, relation];
}

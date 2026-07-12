import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // 'client' | 'helper' | 'admin'
  final String? profileImageUrl;
  final DateTime createdAt;

  // Client-only
  final String? primaryNeedType;

  // Helper-only
  final String? verificationStatus; // 'pending' | 'approved' | 'rejected'
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.createdAt,
    this.profileImageUrl,
    this.primaryNeedType,
    this.verificationStatus,
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
  });

  bool get isClient => role == 'client';
  bool get isHelper => role == 'helper';
  bool get isAdmin => role == 'admin';
  bool get isVerifiedHelper => isHelper && verificationStatus == 'approved';
  bool get isPendingHelper => isHelper && verificationStatus == 'pending';

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        role,
        profileImageUrl,
        createdAt,
        primaryNeedType,
        verificationStatus,
        idFrontUrl,
        idBackUrl,
        selfieUrl,
      ];
}

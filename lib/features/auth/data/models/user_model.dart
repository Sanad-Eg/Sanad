import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/auth/domain/entities/user_entity.dart';

/// Data-layer representation of a user.
/// Extends [UserEntity] and adds Firestore serialization logic.
class UserModel extends UserEntity {
  final String? aboutMe;
  final double? hourlyRate;
  final List<String>? specialties;
  final List<String>? serviceAreas;
  final double? rating;
  final int? reviewCount;
  final int? completedTasksCount;
  final bool? isOnline;
  final double? withdrawableBalance;
  final double? pendingBalance;

  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.role,
    required super.createdAt,
    super.profileImageUrl,
    super.primaryNeedType,
    super.verificationStatus,
    super.idFrontUrl,
    super.idBackUrl,
    super.selfieUrl,
    this.aboutMe,
    this.hourlyRate,
    this.specialties,
    this.serviceAreas,
    this.rating,
    this.reviewCount,
    this.completedTasksCount,
    this.isOnline,
    this.withdrawableBalance,
    this.pendingBalance,
  });

  // ── Factory: Firestore DocumentSnapshot → UserModel ──────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      primaryNeedType: json['primaryNeedType'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
      idFrontUrl: json['idFrontUrl'] as String?,
      idBackUrl: json['idBackUrl'] as String?,
      selfieUrl: json['selfieUrl'] as String?,
      // Firestore stores dates as Timestamps; fall back to DateTime.now()
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      aboutMe: json['aboutMe'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      specialties: json['specialties'] is List
          ? List<String>.from((json['specialties'] as List).map((e) => e.toString()))
          : null,
      serviceAreas: json['serviceAreas'] is List
          ? List<String>.from((json['serviceAreas'] as List).map((e) => e.toString()))
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      completedTasksCount: (json['completedTasksCount'] as num?)?.toInt(),
      isOnline: json['isOnline'] as bool?,
      withdrawableBalance: (json['withdrawableBalance'] as num?)?.toDouble(),
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble(),
    );
  }

  // ── Serialise to Firestore ────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (primaryNeedType != null) 'primaryNeedType': primaryNeedType,
      if (verificationStatus != null) 'verificationStatus': verificationStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      if (aboutMe != null) 'aboutMe': aboutMe,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
      if (specialties != null) 'specialties': specialties,
      if (serviceAreas != null) 'serviceAreas': serviceAreas,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (completedTasksCount != null) 'completedTasksCount': completedTasksCount,
      if (isOnline != null) 'isOnline': isOnline,
      if (withdrawableBalance != null) 'withdrawableBalance': withdrawableBalance,
      if (pendingBalance != null) 'pendingBalance': pendingBalance,
      if (idFrontUrl != null) 'idFrontUrl': idFrontUrl,
      if (idBackUrl != null) 'idBackUrl': idBackUrl,
      if (selfieUrl != null) 'selfieUrl': selfieUrl,
    };
  }

  // ── Convenience: build a fresh client model before Firestore write ────────
  factory UserModel.newClient({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String primaryNeedType,
  }) {
    return UserModel(
      id: uid,
      name: name,
      phone: phone,
      email: email,
      role: 'client',
      primaryNeedType: primaryNeedType,
      createdAt: DateTime.now(),
    );
  }

  // ── Convenience: build a fresh helper model before Firestore write ────────
  factory UserModel.newHelper({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String aboutMe,
    required double hourlyRate,
    required List<String> specialties,
    required List<String> serviceAreas,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
  }) {
    return UserModel(
      id: uid,
      name: name,
      phone: phone,
      email: email,
      role: 'helper',
      verificationStatus: 'pending',
      createdAt: DateTime.now(),
      aboutMe: aboutMe,
      hourlyRate: hourlyRate,
      specialties: specialties,
      serviceAreas: serviceAreas,
      rating: 0.0,
      reviewCount: 0,
      completedTasksCount: 0,
      isOnline: false,
      withdrawableBalance: 0.0,
      pendingBalance: 0.0,
      idFrontUrl: idFrontUrl,
      idBackUrl: idBackUrl,
      selfieUrl: selfieUrl,
    );
  }
}

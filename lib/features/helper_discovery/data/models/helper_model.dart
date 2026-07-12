import 'package:sanad/features/helper_discovery/domain/entities/helper_entity.dart';

class HelperModel extends HelperEntity {
  const HelperModel({
    required super.id,
    required super.name,
    required super.profileImageUrl,
    required super.rating,
    required super.reviewCount,
    required super.completedTasksCount,
    required super.distanceInKm,
    required super.isOnline,
    required super.hourlyRate,
    required super.aboutMe,
    required super.specialties,
    required super.serviceAreas,
    required super.verificationStatus,
  });

  factory HelperModel.fromJson(Map<String, dynamic> json, {double distanceInKm = 0.0}) {
    return HelperModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      completedTasksCount: (json['completedTasksCount'] as num?)?.toInt() ?? 0,
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble() ?? distanceInKm,
      isOnline: json['isOnline'] as bool? ?? false,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      aboutMe: json['aboutMe'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      serviceAreas: (json['serviceAreas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'completedTasksCount': completedTasksCount,
      'isOnline': isOnline,
      'hourlyRate': hourlyRate,
      'aboutMe': aboutMe,
      'specialties': specialties,
      'serviceAreas': serviceAreas,
      'verificationStatus': verificationStatus,
    };
  }
}

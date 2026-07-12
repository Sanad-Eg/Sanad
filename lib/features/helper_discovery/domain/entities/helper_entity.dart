import 'package:equatable/equatable.dart';

class HelperEntity extends Equatable {
  final String id;
  final String name;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final int completedTasksCount;
  final double distanceInKm;
  final bool isOnline;
  final double hourlyRate;
  final String aboutMe;
  final List<String> specialties;
  final List<String> serviceAreas;
  final String verificationStatus; // 'pending' | 'verified' | 'rejected'

  const HelperEntity({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.completedTasksCount,
    required this.distanceInKm,
    required this.isOnline,
    required this.hourlyRate,
    required this.aboutMe,
    required this.specialties,
    required this.serviceAreas,
    required this.verificationStatus,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        profileImageUrl,
        rating,
        reviewCount,
        completedTasksCount,
        distanceInKm,
        isOnline,
        hourlyRate,
        aboutMe,
        specialties,
        serviceAreas,
        verificationStatus,
      ];
}

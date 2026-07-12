import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  negotiating,
  confirmed,
  inProgress,
  confirmingCompletion,
  completed,
  cancelled,
  expired,
  disputed,
}

class BookingEntity extends Equatable {
  final String id;
  final String clientId;
  final String helperId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final String taskDescription;
  final double proposedHourlyRate;
  final double? agreedHourlyRate;
  final double? agreedPrice;
  final double? totalAmount;
  final BookingStatus status;
  final int negotiationRound; // 0, 1, or 2
  final String? helperNote;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? paidAt;
  final DateTime? completionRequestedAt;
  final bool clientConfirmed;
  final bool helperConfirmed;

  const BookingEntity({
    required this.id,
    required this.clientId,
    required this.helperId,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.taskDescription,
    required this.proposedHourlyRate,
    this.agreedHourlyRate,
    this.agreedPrice,
    this.totalAmount,
    required this.status,
    required this.negotiationRound,
    this.helperNote,
    required this.createdAt,
    this.confirmedAt,
    this.paidAt,
    this.completionRequestedAt,
    required this.clientConfirmed,
    required this.helperConfirmed,
  });

  BookingEntity copyWith({
    String? id,
    String? clientId,
    String? helperId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? taskDescription,
    double? proposedHourlyRate,
    double? Function()? agreedHourlyRate,
    double? Function()? agreedPrice,
    double? Function()? totalAmount,
    BookingStatus? status,
    int? negotiationRound,
    String? Function()? helperNote,
    DateTime? createdAt,
    DateTime? Function()? confirmedAt,
    DateTime? Function()? paidAt,
    DateTime? Function()? completionRequestedAt,
    bool? clientConfirmed,
    bool? helperConfirmed,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      helperId: helperId ?? this.helperId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      taskDescription: taskDescription ?? this.taskDescription,
      proposedHourlyRate: proposedHourlyRate ?? this.proposedHourlyRate,
      agreedHourlyRate: agreedHourlyRate != null ? agreedHourlyRate() : this.agreedHourlyRate,
      agreedPrice: agreedPrice != null ? agreedPrice() : this.agreedPrice,
      totalAmount: totalAmount != null ? totalAmount() : this.totalAmount,
      status: status ?? this.status,
      negotiationRound: negotiationRound ?? this.negotiationRound,
      helperNote: helperNote != null ? helperNote() : this.helperNote,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt != null ? confirmedAt() : this.confirmedAt,
      paidAt: paidAt != null ? paidAt() : this.paidAt,
      completionRequestedAt: completionRequestedAt != null ? completionRequestedAt() : this.completionRequestedAt,
      clientConfirmed: clientConfirmed ?? this.clientConfirmed,
      helperConfirmed: helperConfirmed ?? this.helperConfirmed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        helperId,
        startTime,
        endTime,
        durationHours,
        latitude,
        longitude,
        locationAddress,
        taskDescription,
        proposedHourlyRate,
        agreedHourlyRate,
        agreedPrice,
        totalAmount,
        status,
        negotiationRound,
        helperNote,
        createdAt,
        confirmedAt,
        paidAt,
        completionRequestedAt,
        clientConfirmed,
        helperConfirmed,
      ];
}

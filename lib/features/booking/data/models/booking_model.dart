import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';

/// Data-layer representation of a booking.
/// Extends [BookingEntity] and handles Firestore Timestamp ↔ DateTime conversion.
class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.clientId,
    required super.helperId,
    required super.startTime,
    required super.endTime,
    required super.durationHours,
    required super.latitude,
    required super.longitude,
    required super.locationAddress,
    required super.taskDescription,
    required super.proposedHourlyRate,
    super.agreedHourlyRate,
    super.agreedPrice,
    super.totalAmount,
    required super.status,
    required super.negotiationRound,
    super.helperNote,
    required super.createdAt,
    super.confirmedAt,
    super.paidAt,
    super.completionRequestedAt,
    required super.clientConfirmed,
    required super.helperConfirmed,
  });

  // ── Factory: Firestore DocumentSnapshot → BookingModel ───────────────────
  // Takes both the document data map AND the document ID separately,
  // because Firestore doc IDs are not stored inside the data map.
  factory BookingModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return BookingModel(
      id: documentId,
      clientId: json['clientId'] as String? ?? '',
      helperId: json['helperId'] as String? ?? '',
      startTime: _toDateTime(json['startTime']) ?? DateTime.now(),
      endTime: _toDateTime(json['endTime']) ?? DateTime.now(),
      durationHours: (json['durationHours'] as num?)?.toInt() ?? 1,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationAddress: json['locationAddress'] as String? ?? '',
      taskDescription: json['taskDescription'] as String? ?? '',
      proposedHourlyRate:
          (json['proposedHourlyRate'] as num?)?.toDouble() ?? 0.0,
      agreedHourlyRate: (json['agreedHourlyRate'] as num?)?.toDouble(),
      agreedPrice: json['agreedPrice'] != null
          ? (json['agreedPrice'] as num).toDouble()
          : null,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      status: _parseStatus(json['status'] as String?),
      negotiationRound: (json['negotiationRound'] as num?)?.toInt() ?? 0,
      helperNote: json['helperNote'] as String?,
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      confirmedAt: _toDateTime(json['confirmedAt']),
      paidAt: _toDateTime(json['paidAt']),
      completionRequestedAt: _toDateTime(json['completionRequestedAt']),
      clientConfirmed: json['clientConfirmed'] as bool? ?? false,
      helperConfirmed: json['helperConfirmed'] as bool? ?? false,
    );
  }

  // ── Serialise to Firestore ────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      // NOTE: `id` is the Firestore document ID — not stored in the document body.
      'clientId': clientId,
      'helperId': helperId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationHours': durationHours,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'taskDescription': taskDescription,
      'proposedHourlyRate': proposedHourlyRate,
      'agreedHourlyRate': agreedHourlyRate,
      'agreedPrice': agreedPrice,
      'totalAmount': totalAmount,
      'status': status.name,
      'negotiationRound': negotiationRound,
      'helperNote': helperNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt':
          confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'completionRequestedAt': completionRequestedAt != null
          ? Timestamp.fromDate(completionRequestedAt!)
          : null,
      'clientConfirmed': clientConfirmed,
      'helperConfirmed': helperConfirmed,
    };
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  /// Safely converts a Firestore field to [DateTime].
  /// Handles three possible types:
  ///   - [Timestamp]  → from Firestore native storage
  ///   - [String]     → from JSON-over-HTTP or legacy data
  ///   - null         → returns null
  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Maps a raw Firestore string value to the [BookingStatus] enum.
  /// Defaults to [BookingStatus.pending] for unknown or null values.
  static BookingStatus _parseStatus(String? raw) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => BookingStatus.pending,
    );
  }
}

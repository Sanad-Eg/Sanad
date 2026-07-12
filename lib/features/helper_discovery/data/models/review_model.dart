import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/helper_discovery/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.helperId,
    required super.clientId,
    required super.clientName,
    required super.rating,
    required super.reviewText,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      bookingId: json['bookingId'] as String? ?? '',
      helperId: json['helperId'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      clientName: json['clientName'] as String? ?? 'عميل',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: json['reviewText'] as String? ?? '',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'helperId': helperId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String helperId;
  final String clientId;
  final String clientName;
  final double rating;
  final String reviewText;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.helperId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        helperId,
        clientId,
        clientName,
        rating,
        reviewText,
        createdAt,
      ];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sanad/features/booking/data/models/booking_model.dart';
import 'package:sanad/features/booking/domain/entities/booking_entity.dart';
import 'package:sanad/core/services/notification_sender_service.dart';

/// Firestore implementation of [BookingRemoteDataSource].
/// All Firebase I/O for the booking feature is isolated here.
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const String _collection = 'bookings';

  BookingRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // ── Helper: get a typed CollectionReference ───────────────────────────────
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(_collection);

  // ── Helper: fetch + parse a single document ───────────────────────────────
  Future<BookingModel> _fetchModel(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('حجز غير موجود: $bookingId');
    }
    return BookingModel.fromFirestore(doc.data()!, doc.id);
  }

  // ── Create ────────────────────────────────────────────────────────────────
  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    // Let Firestore auto-generate the document ID
    final docRef = _bookings.doc();
    await docRef.set(booking.toJson());

    // Trigger notification asynchronously
    _sendBookingNotificationAsync(
      recipientId: booking.helperId,
      title: 'طلب حجز جديد',
      body: 'لديك طلب خدمة جديد، يرجى المراجعة.',
      bookingId: docRef.id,
    );

    // Return the model with the real Firestore-generated ID
    return BookingModel.fromFirestore(booking.toJson(), docRef.id);
  }

  // ── Update Status (generic internal helper) ───────────────────────────────
  @override
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    await _bookings.doc(bookingId).update({'status': newStatus.name});
    final updated = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(updated);
    return updated;
  }

  // ── Accept ────────────────────────────────────────────────────────────────
  @override
  Future<BookingModel> acceptBooking(String bookingId, double agreedPrice) async {
    if (agreedPrice <= 0) {
      throw Exception('لا يمكن قبول أو بدء الطلب بدون تحديد السعر النهائي.');
    }
    final current = await _fetchModel(bookingId);
    final total = agreedPrice * current.durationHours;

    await _bookings.doc(bookingId).update({
      'status': BookingStatus.confirmed.name,
      'agreedHourlyRate': agreedPrice,
      'agreedPrice': agreedPrice,
      'totalAmount': total,
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    final updated = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(updated);
    return updated;
  }

  // ── Reject ────────────────────────────────────────────────────────────────
  @override
  Future<BookingModel> rejectBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
    });
    final updated = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(updated);
    return updated;
  }

  // ── Counter Offer ─────────────────────────────────────────────────────────
  @override
  Future<BookingModel> counterOffer({
    required String bookingId,
    required double newPrice,
    required String note,
  }) async {
    final current = await _fetchModel(bookingId);

    // Enforce max 2 negotiation rounds as per business rules
    if (current.negotiationRound >= 2) {
      throw Exception('تجاوز الحد الأقصى للتفاوض (جولتان)');
    }

    await _bookings.doc(bookingId).update({
      'status': BookingStatus.negotiating.name,
      'proposedHourlyRate': newPrice,
      'negotiationRound': current.negotiationRound + 1,
      'helperNote': note,
    });

    final updated = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(updated);
    return updated;
  }

  // ── Pay (Escrow Lock) ─────────────────────────────────────────────────────
  @override
  Future<BookingModel> payBooking(String bookingId) async {
    final current = await _fetchModel(bookingId);
    final agreedPrice = current.agreedPrice ?? current.agreedHourlyRate;
    if (agreedPrice == null || agreedPrice <= 0) {
      throw Exception('لا يمكن قبول أو بدء الطلب بدون تحديد السعر النهائي.');
    }
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.inProgress.name,
      'paidAt': FieldValue.serverTimestamp(),
    });
    final updated = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(updated);
    return updated;
  }

  // ── Dual Completion Confirmation ──────────────────────────────────────────
  @override
  Future<BookingModel> confirmCompletion({
    required String bookingId,
    required bool isClient,
  }) async {
    // First, record this side's confirmation
    final fieldToSet = isClient ? 'clientConfirmed' : 'helperConfirmed';
    await _bookings.doc(bookingId).update({fieldToSet: true});

    // Re-fetch to check if BOTH sides have now confirmed
    final updated = await _fetchModel(bookingId);

    if (updated.clientConfirmed && updated.helperConfirmed) {
      // Both confirmed → complete the booking and release escrow
      await _bookings.doc(bookingId).update({
        'status': BookingStatus.completed.name,
      });

      final helperRef = _firestore.collection('users').doc(updated.helperId);
      try {
        await _firestore.runTransaction((transaction) async {
          final helperSnapshot = await transaction.get(helperRef);
          if (helperSnapshot.exists) {
            final data = helperSnapshot.data();
            if (data != null) {
              final currentCount = (data['completedTasksCount'] as num?)?.toInt() ?? 0;
              final newCount = currentCount + 1;
              transaction.update(helperRef, {
                'completedTasksCount': newCount,
                'completedTasks': newCount,
              });
            }
          }
        });
      } catch (_) {}

      final completed = await _fetchModel(bookingId);
      _notifyCustomerOfStatusUpdate(completed);
      return completed;
    }

    // Only one side confirmed so far → pending the other's confirmation
    await _bookings.doc(bookingId).update({
      'status': BookingStatus.confirmingCompletion.name,
      'completionRequestedAt': FieldValue.serverTimestamp(),
    });

    final pending = await _fetchModel(bookingId);
    _notifyCustomerOfStatusUpdate(pending);
    return pending;
  }

  // ── Real-time Stream ──────────────────────────────────────────────────────
  @override
  Stream<BookingModel> getBookingStream(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('حجز غير موجود: $bookingId');
      }
      return BookingModel.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  @override
  Stream<BookingEntity> trackBooking(String bookingId) {
    return _bookings.doc(bookingId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('حجز غير موجود: $bookingId');
      }
      return BookingModel.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  @override
  Stream<List<BookingModel>> getMyBookings({
    required String userId,
    required String role,
    List<BookingStatus>? statuses,
  }) {
    Query<Map<String, dynamic>> query = _bookings;

    if (role == 'helper') {
      query = query.where('helperId', isEqualTo: userId);
    } else {
      query = query.where('clientId', isEqualTo: userId);
    }

    if (statuses != null && statuses.isNotEmpty) {
      query = query.where(
        'status',
        whereIn: statuses.map((e) => e.name).toList(),
      );
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return BookingModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      // Sort in-memory to prevent index errors in Firestore
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Stream<List<BookingModel>> getClientBookingsStream(String clientId) {
    return _bookings
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Stream<List<BookingModel>> getHelperBookingsStream(String helperId) {
    return _bookings
        .where('helperId', isEqualTo: helperId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  void _notifyCustomerOfStatusUpdate(BookingModel booking) {
    _sendBookingNotificationAsync(
      recipientId: booking.clientId,
      title: 'تحديث في حالة الحجز',
      body: 'تم تحديث حالة طلبك.',
      bookingId: booking.id,
    );
  }

  Future<void> _sendBookingNotificationAsync({
    required String recipientId,
    required String title,
    required String body,
    required String bookingId,
  }) async {
    // Run asynchronously to avoid blocking the DB write/UI thread
    Future.microtask(() async {
      try {
        if (recipientId.isEmpty) return;

        // Fetch recipient user document to get FCM token
        final doc = await _firestore.collection('users').doc(recipientId).get();
        if (!doc.exists) {
          return;
        }

        final token = doc.data()?['fcmToken'] as String?;
        if (token == null || token.isEmpty) {
          return;
        }

        // Send push notification using NotificationSenderService
        await NotificationSenderService().sendNotification(
          targetFcmToken: token,
          title: title,
          body: body,
          data: {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'route': '/booking-track/$bookingId',
            'bookingId': bookingId,
            'type': 'booking',
          },
        );
      } catch (_) {}
    });
  }

  @override
  Future<void> submitReview({
    required String bookingId,
    required String helperId,
    required String clientId,
    required double rating,
    required String reviewText,
  }) async {
    String clientName = 'عميل';
    try {
      final clientDoc = await _firestore.collection('users').doc(clientId).get();
      if (clientDoc.exists && clientDoc.data() != null) {
        clientName = clientDoc.data()?['name'] as String? ?? 'عميل';
      }
    } catch (_) {}

    final reviewRef = _firestore.collection('reviews').doc();
    await reviewRef.set({
      'id': reviewRef.id,
      'bookingId': bookingId,
      'helperId': helperId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _bookings.doc(bookingId).update({
      'isRated': true,
      'rating': rating,
      'reviewText': reviewText,
    });

    final helperRef = _firestore.collection('users').doc(helperId);
    await _firestore.runTransaction((transaction) async {
      final helperSnapshot = await transaction.get(helperRef);
      if (helperSnapshot.exists) {
        final data = helperSnapshot.data();
        if (data != null) {
          final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
          final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

          final newCount = currentCount + 1;
          final newRating = ((currentRating * currentCount) + rating) / newCount;

          transaction.update(helperRef, {
            'rating': newRating,
            'averageRating': newRating,
            'reviewCount': newCount,
            'ratingCount': newCount,
          });
        }
      }
    });
  }
}


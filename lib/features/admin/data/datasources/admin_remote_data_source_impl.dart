import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/auth/data/models/user_model.dart';
import 'package:sanad/features/booking/data/models/booking_model.dart';
import 'package:sanad/features/admin/data/datasources/admin_remote_data_source.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<UserModel>> getPendingHelpers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'helper')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // If data doesn't have 'id', populate it from the document reference ID.
        if (data['id'] == null) {
          data['id'] = doc.id;
        }
        return UserModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['id'] == null) {
          data['id'] = doc.id;
        }
        return UserModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<BookingModel>> getAllBookingsStream() {
    return _firestore
        .collection('bookings')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return BookingModel.fromFirestore(data, doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> updateHelperVerificationStatus({
    required String helperId,
    required String status,
  }) async {
    await _firestore.collection('users').doc(helperId).update({
      'verificationStatus': status,
    });
  }

  @override
  Future<void> approveHelper(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'verificationStatus': 'approved',
    });
  }
}

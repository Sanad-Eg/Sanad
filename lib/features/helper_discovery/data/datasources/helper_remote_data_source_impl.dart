import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/helper_discovery/data/datasources/helper_remote_data_source.dart';
import 'package:sanad/features/helper_discovery/data/models/helper_model.dart';
import 'package:sanad/features/helper_discovery/data/models/review_model.dart';

class HelperRemoteDataSourceImpl implements HelperRemoteDataSource {
  final FirebaseFirestore _firestore;

  HelperRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<List<HelperModel>> getHelpers({
    String? specialty,
    String? query,
  }) async {
    // Base query: only admin-approved helpers
    Query<Map<String, dynamic>> q = _firestore
        .collection('users')
        .where('role', isEqualTo: 'helper')
        .where('verificationStatus', isEqualTo: 'approved');

    // Filter by specialty (Firestore array-contains)
    if (specialty != null &&
        specialty.isNotEmpty &&
        specialty.toLowerCase() != 'all') {
      q = q.where('specialties', arrayContains: specialty);
    }

    try {
      final snapshot = await q.get();

      final helpers = <HelperModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          helpers.add(HelperModel.fromJson(data));
        } catch (_) {
          // Log parsing error silently or handle failure gracefully for production
        }
      }

      // Client-side name filter (Firestore doesn't support full-text search)
      if (query != null && query.isNotEmpty) {
        final lower = query.toLowerCase();
        return helpers
            .where((h) => h.name.toLowerCase().contains(lower))
            .toList();
      }

      return helpers;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<HelperModel> getHelperProfile(String helperId) async {
    final doc = await _firestore.collection('users').doc(helperId).get();
    if (!doc.exists) {
      throw Exception('Helper profile not found for id: $helperId');
    }
    final data = doc.data()!;
    data['id'] = doc.id;
    return HelperModel.fromJson(data);
  }

  @override
  Stream<HelperModel> getHelperProfileStream(String helperId) {
    return _firestore.collection('users').doc(helperId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Helper profile not found for id: $helperId');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return HelperModel.fromJson(data);
    });
  }

  @override
  Stream<List<ReviewModel>> getHelperReviews(String helperId) {
    return _firestore
        .collection('reviews')
        .where('helperId', isEqualTo: helperId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReviewModel.fromJson(data);
      }).toList();
    });
  }
}

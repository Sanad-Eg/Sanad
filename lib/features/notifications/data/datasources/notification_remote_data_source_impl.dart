import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:sanad/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _notificationsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationsCollection(userId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      // Sort descending chronologically
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markAsRead(String notificationId, String userId) async {
    await _notificationsCollection(userId).doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final col = _notificationsCollection(userId);
    final unreadQuery = await col.where('isRead', isEqualTo: false).get();

    if (unreadQuery.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}

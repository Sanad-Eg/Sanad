import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanad/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sanad/features/chat/data/models/chat_model.dart';
import 'package:sanad/features/chat/data/models/message_model.dart';
import 'package:sanad/core/services/notification_sender_service.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  @override
  Stream<List<ChatModel>> getMyChats(String userId) {
    // Query where user is either the client or helper
    return _chats
        .where(
          Filter.or(
            Filter('clientId', isEqualTo: userId),
            Filter('helperId', isEqualTo: userId),
          ),
        )
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ChatModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      // Sort in-memory to prevent index errors in Firestore
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  @override
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      // Sort in-memory to ensure chronological order
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  @override
  Stream<ChatModel> getChatStream(String chatId) {
    return _chats.doc(chatId).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        // Try to fetch booking and participant names
        try {
          final bookingSnapshot = await _firestore.collection('bookings').doc(chatId).get();
          if (bookingSnapshot.exists) {
            final bookingData = bookingSnapshot.data();
            final clientId = bookingData?['clientId'] as String? ?? '';
            final helperId = bookingData?['helperId'] as String? ?? '';

            String clientName = 'العميل';
            String helperName = 'المساعد';

            if (clientId.isNotEmpty) {
              final clientDoc = await _firestore.collection('users').doc(clientId).get();
              clientName = clientDoc.data()?['name'] as String? ?? 'العميل';
            }
            if (helperId.isNotEmpty) {
              final helperDoc = await _firestore.collection('users').doc(helperId).get();
              helperName = helperDoc.data()?['name'] as String? ?? 'المساعد';
            }

            return ChatModel(
              id: chatId,
              bookingId: chatId,
              clientId: clientId,
              helperId: helperId,
              clientName: clientName,
              helperName: helperName,
              lastMessage: '',
              updatedAt: DateTime.now(),
              unreadCount: 0,
            );
          }
        } catch (e) {
          // Fallback to defaults on error
        }
        return ChatModel(
          id: chatId,
          bookingId: chatId,
          clientId: '',
          helperId: '',
          clientName: 'العميل',
          helperName: 'المساعد',
          lastMessage: '',
          updatedAt: DateTime.now(),
          unreadCount: 0,
        );
      }
      return ChatModel.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    final chatDocRef = _chats.doc(message.chatId);
    final chatSnapshot = await chatDocRef.get();

    final batch = _firestore.batch();
    final messageDocRef = chatDocRef.collection('messages').doc();

    // Write the message into the sub-collection
    batch.set(messageDocRef, message.toJson());

    String clientId = '';
    String helperId = '';
    String clientName = 'العميل';
    String helperName = 'المساعد';

    if (!chatSnapshot.exists) {
      // Document does not exist, fetch metadata to create it fully
      try {
        final bookingSnapshot = await _firestore.collection('bookings').doc(message.chatId).get();
        if (bookingSnapshot.exists) {
          final bookingData = bookingSnapshot.data();
          clientId = bookingData?['clientId'] as String? ?? '';
          helperId = bookingData?['helperId'] as String? ?? '';

          if (clientId.isNotEmpty) {
            final clientDoc = await _firestore.collection('users').doc(clientId).get();
            clientName = clientDoc.data()?['name'] as String? ?? 'العميل';
          }
          if (helperId.isNotEmpty) {
            final helperDoc = await _firestore.collection('users').doc(helperId).get();
            helperName = helperDoc.data()?['name'] as String? ?? 'المساعد';
          }
        }
      } catch (e) {
        // Fallback
      }

      batch.set(
        chatDocRef,
        {
          'bookingId': message.chatId,
          'clientId': clientId,
          'helperId': helperId,
          'clientName': clientName,
          'helperName': helperName,
          'lastMessage': message.content,
          'updatedAt': FieldValue.serverTimestamp(),
          'unreadCount': 1,
        },
        SetOptions(merge: true),
      );
    } else {
      // Document exists, extract info to determine recipient and sender names
      final chatData = chatSnapshot.data();
      clientId = chatData?['clientId'] as String? ?? '';
      helperId = chatData?['helperId'] as String? ?? '';
      clientName = chatData?['clientName'] as String? ?? 'العميل';
      helperName = chatData?['helperName'] as String? ?? 'المساعد';

      batch.set(
        chatDocRef,
        {
          'lastMessage': message.content,
          'updatedAt': FieldValue.serverTimestamp(),
          'unreadCount': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    // Trigger Notification Asynchronously after successful write
    _sendPushNotificationAsync(
      message: message,
      clientId: clientId,
      helperId: helperId,
      clientName: clientName,
      helperName: helperName,
    );
  }

  void _sendPushNotificationAsync({
    required MessageModel message,
    required String clientId,
    required String helperId,
    required String clientName,
    required String helperName,
  }) {
    // Run asynchronously to not block the chat flow UI
    Future.microtask(() async {
      try {
        String recipientId = '';

        // Fallback 1: If chatId is a combination of two UIDs (e.g. senderId_recipientId)
        if (message.chatId.contains('_')) {
          final parts = message.chatId.split('_');
          if (parts.length == 2) {
            recipientId = (parts[0] == message.senderId) ? parts[1] : parts[0];
          }
        }

        // Fallback 2: Use passed/fetched clientId and helperId
        if (recipientId.isEmpty) {
          recipientId = (message.senderId == clientId) ? helperId : clientId;
        }

        // Fallback 3: Query the bookings document if recipientId is still empty
        if (recipientId.isEmpty) {
          try {
            final bookingDoc = await _firestore.collection('bookings').doc(message.chatId).get();
            if (bookingDoc.exists) {
              final bData = bookingDoc.data();
              final bClient = bData?['clientId'] as String? ?? '';
              final bHelper = bData?['helperId'] as String? ?? '';
              recipientId = (message.senderId == bClient) ? bHelper : bClient;
            }
          } catch (_) {}
        }

        if (recipientId.isEmpty) return;

        // Fetch recipient's document
        final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
        if (!recipientDoc.exists) return;

        final fcmToken = recipientDoc.data()?['fcmToken'] as String?;
        if (fcmToken == null || fcmToken.isEmpty) return;

        // Determine sender's name
        String senderName = (message.senderId == clientId) ? clientName : helperName;
        if (senderName == 'العميل' || senderName == 'المساعد') {
          // Try to fetch actual sender's name from users collection
          try {
            final senderDoc = await _firestore.collection('users').doc(message.senderId).get();
            if (senderDoc.exists) {
              senderName = senderDoc.data()?['name'] as String? ?? senderName;
            }
          } catch (_) {}
        }

        // Trigger Notification via NotificationSenderService
        await NotificationSenderService().sendNotification(
          targetFcmToken: fcmToken,
          title: senderName,
          body: message.content,
          data: {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'chatId': message.chatId,
            'type': 'chat',
            'senderId': message.senderId,
            'senderName': senderName,
          },
        );
      } catch (e) {
        // Silently catch notification errors
      }
    });
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final chatDocRef = _chats.doc(chatId);

    // Fetch only unread messages (single-field query — no composite index needed).
    // Filter by senderId in Dart to avoid the FAILED_PRECONDITION index error
    // that occurs when combining isNotEqualTo + isEqualTo on different fields.
    final unreadQuery = await chatDocRef
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadQuery.docs) {
      final data = doc.data();
      // Only mark messages sent by the OTHER party as read
      if (data['senderId'] != userId) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    // Reset unread counter; use merge so the doc is created if absent
    batch.set(chatDocRef, {'unreadCount': 0}, SetOptions(merge: true));

    await batch.commit();
  }
}

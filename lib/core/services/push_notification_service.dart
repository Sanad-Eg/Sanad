import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sanad/core/router/app_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  PushNotificationService._privateConstructor();
  static final PushNotificationService _instance = PushNotificationService._privateConstructor();
  factory PushNotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> init() async {
    // 1. Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');

    // 2. Set up Android Foreground Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Listen to token refreshes
    _messaging.onTokenRefresh.listen((token) async {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
          log('Refreshed FCM Token synced to Firestore for user: ${user.uid}');
        } catch (e) {
          log('Error saving refreshed FCM Token to Firestore: $e');
        }
      }
    });

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.notification?.title}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: 'ic_notification',
            ),
          ),
        );
      }
    });

    // 5. Handle Background Messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 6. Handle Background/Terminated Notification Clicks (Deep Linking)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification clicked (app in background): ${message.messageId}');
      _handleNotificationClick(message);
    });

    // Check if the app was opened from a terminated state via a notification click
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('Notification clicked (app was terminated): ${message.messageId}');
        _handleNotificationClick(message);
      }
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final chatId = data['chatId'] as String?;

    log('Handling notification click: type=$type, chatId=$chatId');

    if (type == 'chat' && chatId != null && chatId.isNotEmpty) {
      final senderId = data['senderId'] as String?;
      final senderName = data['senderName'] as String?;
      
      // Use the global GoRouter router instance to navigate
      AppRouter.router?.push(
        '/chat/$chatId',
        extra: {
          'otherPartyId': senderId ?? '',
          'otherPartyName': senderName ?? '',
        },
      );
    }
  }

  /// Syncs the FCM Device Token to the current authenticated user's Firestore document.
  Future<void> syncTokenToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        String? token = await _messaging.getToken();
        if (token != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
          log('FCM Token synced to Firestore for user: ${user.uid}');
        } else {
          log('FCM Token retrieved is null.');
        }
      } catch (e) {
        log('Error syncing FCM Token to Firestore: $e');
      }
    } else {
      log('FCM Token sync aborted: no user is currently signed in.');
    }
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// FCM Service - Firebase Cloud Messaging Integration
/// Handles global push notifications, token management, and topic subscriptions
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  final Set<String> _recentNotifications = {};

  /// Initialize FCM service
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM: User granted permission');
    } else {
      print('FCM: User declined or has not accepted permission');
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Configure message handlers
    _configureForegroundMessageHandler();
    _configureBackgroundMessageHandler();
    _configureNotificationTapHandler();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
      // Update token in Firestore
    });
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    if (_fcmToken == null) {
      _fcmToken = await _firebaseMessaging.getToken();
    }
    return _fcmToken;
  }

  /// Save FCM token to Firestore for the user
  Future<void> saveFCMToken(String userId) async {
    final token = await getToken();
    if (token == null) return;

    await _firestore.collection('users').doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([
        {
          'token': token,
          'platform': 'android', // TODO: Detect platform dynamically
          'lastUpdated': FieldValue.serverTimestamp(),
          'isActive': true,
        }
      ])
    }, SetOptions(merge: true));

    print('FCM: Token saved to Firestore for user $userId');
  }

  /// Subscribe to a topic (e.g., "all_users", "cds_exam")
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('FCM: Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('FCM: Unsubscribed from topic: $topic');
  }

  /// Configure handler for foreground messages
  void _configureForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM: Message received in foreground');
      print('Notification: ${message.notification?.title}');
      print('Data: ${message.data}');

      // Show local notification for foreground messages
      if (message.notification != null) {
        _showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'Prahaar',
          body: message.notification!.body ?? '',
          data: message.data,
        );
      }
    });
  }

  /// Configure handler for background messages
  void _configureBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  /// Configure handler for notification taps
  void _configureNotificationTapHandler() {
    // Handle notification opened app from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM: Notification opened app from background');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a terminated state notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('FCM: App opened from terminated state via notification');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Show local notification with deduplication
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Deduplication check (prevents showing same notification twice)
    final dedupeKey = '$id-${DateTime.now().minute}';
    if (_recentNotifications.contains(dedupeKey)) {
      print('FCM: Duplicate notification blocked: $dedupeKey');
      return;
    }

    _recentNotifications.add(dedupeKey);
    Future.delayed(const Duration(seconds: 60), () {
      _recentNotifications.remove(dedupeKey);
    });

    // Show notification
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_default_channel',
      'Global Notifications',
      channelDescription: 'Global push notifications from Prahaar',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: data?['screen'], // For navigation
    );
  }

  /// Handle notification tap - navigate to appropriate screen
  void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'];
    final type = data['type'];

    print('FCM: Notification tapped - Screen: $screen, Type: $type');

    // TODO: Implement navigation based on screen/type
    // Example:
    // if (screen == 'habit_tracker') {
    //   navigatorKey.currentState?.pushNamed('/habit_tracker');
    // }
  }

  /// Schedule a global notification (stored in Firestore, triggered by Cloud Function)
  Future<void> scheduleGlobalNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String scheduledTime, // Format: "HH:mm"
    String recurrence = 'daily',
    Map<String, dynamic>? additionalData,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scheduledNotifications')
        .add({
      'type': type,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime,
      'recurrence': recurrence,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    });

    print('FCM: Global notification scheduled for $userId at $scheduledTime');
  }

  /// Cancel a scheduled global notification
  Future<void> cancelScheduledNotification(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scheduledNotifications')
        .doc(notificationId)
        .update({'isActive': false});

    print('FCM: Scheduled notification $notificationId cancelled');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('FCM: Background message received');
  print('Notification: ${message.notification?.title}');
  print('Data: ${message.data}');
  
  // Background messages are automatically shown by FCM
  // No need to manually display notification
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/fcm_service.dart';

/// FCM Service Provider - Singleton instance
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

/// FCM Token Provider - Stream of current FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final fcmService = ref.watch(fcmServiceProvider);
  return await fcmService.getToken();
});

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/notification_service.dart';
import 'package:prahar/core/services/fcm_service.dart';  // FCM Service
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/auth/screens/auth_wrapper.dart';
import 'package:prahar/features/splash/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Skip notification services on web (not supported)
  if (!kIsWeb) {
    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.init();
    
    // Request notification permissions
    await notificationService.requestPermission();
    
    // Schedule global notifications (study reminders, habits, mock tests, motivational quotes)
    await notificationService.scheduleGlobalNotifications();
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Skip FCM on web (subscribeToTopic not supported)
  if (!kIsWeb) {
    // Initialize FCM Service (after Firebase init)
    final fcmService = FCMService();
    await fcmService.initialize();
    
    // Subscribe to "all_users" topic for global notifications
    await fcmService.subscribeToTopic('all_users');
  }

  // Wrap the entire app in a ProviderScope for Riverpod
  runApp(const ProviderScope(child: PraharApp()));
}

class PraharApp extends StatelessWidget {
  const PraharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prahar',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
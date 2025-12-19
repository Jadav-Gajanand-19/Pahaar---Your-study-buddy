import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification Channel IDs
  static const String habitChannel = 'habit_reminders_channel';
  static const String revisionChannel = 'revision_reminders_channel';
  static const String motivationChannel = 'daily_motivation_channel';
  static const String achievementChannel = 'achievement_alerts_channel';
  static const String examChannel = 'exam_countdown_channel';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    tz.initializeTimeZones();
    await _createNotificationChannels();
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Add navigation logic based on payload
    print('Notification tapped: ${response.payload}');
  }

  // Create all notification channels
  Future<void> _createNotificationChannels() async {
    final channels = [
      const AndroidNotificationChannel(
        habitChannel,
        'Directive Reminders',
        description: 'Reminders for your daily directives and habits',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        revisionChannel,
        'Revision Alerts',
        description: 'Notifications for revision topics that are due',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        motivationChannel,
        'Daily Motivation',
        description: 'Daily motivational messages to keep you on track',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        achievementChannel,
        'Achievement Alerts',
        description: 'Notifications when you unlock new achievements',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        examChannel,
        'Exam Countdown',
        description: 'Notifications about upcoming exam milestones',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: true,
      ),
    ];

    for (var channel in channels) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check if notification permission is granted
  Future<bool> hasPermission() async {
    return await Permission.notification.isGranted;
  }

  // Schedule daily habit/directive reminder
  Future<void> scheduleDailyHabitReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(scheduledTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          habitChannel,
          'Directive Reminders',
          channelDescription: 'Reminders for your daily directives and habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit:$id',
    );
  }

  // Schedule revision topic reminder
  Future<void> scheduleRevisionReminder({
    required int id,
    required String topicName,
    required String subject,
    required DateTime dueDate,
    TimeOfDay? reminderTime,
  }) async {
    final scheduledTime = reminderTime ?? const TimeOfDay(hour: 18, minute: 0);
    
    final scheduleDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Only schedule if date is in the future
    if (scheduleDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '📚 Revision Due: $subject',
        'Time to revise: $topicName',
        scheduleDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            revisionChannel,
            'Revision Alerts',
            channelDescription: 'Notifications for revision topics that are due',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'revision:$id',
      );
    }
  }

  // Schedule daily motivation notification
  Future<void> scheduleDailyMotivation({
    required TimeOfDay time,
  }) async {
    const motivationalMessages = [
      'Soldier! Time to execute your mission. Every directive completed is a victory!',
      'Rise and shine, Cadet! Your country needs prepared officers. Move out!',
      'No retreat, no surrender! Today\'s directives await your command.',
      'Discipline today, success tomorrow. Execute your daily ops!',
      'Your dedication today shapes your destiny tomorrow. Stay mission-focused!',
    ];

    final message = motivationalMessages[DateTime.now().day % motivationalMessages.length];

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999999, // Fixed ID for daily motivation
      '💪 REVEILLE - Daily Briefing',
      message,
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          motivationChannel,
          'Daily Motivation',
          channelDescription: 'Daily motivational messages to keep you on track',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'motivation',
    );
  }

  // Show instant achievement notification
  Future<void> showAchievementNotification({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      '🏆 Achievement Unlocked!',
      '$achievementTitle - $achievementDescription',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          achievementChannel,
          'Achievement Alerts',
          channelDescription: 'Notifications when you unlock new achievements',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'achievement',
    );
  }

  // Show exam countdown notification
  Future<void> showExamCountdownNotification({
    required int daysRemaining,
    required String examType,
  }) async {
    String message;
    if (daysRemaining == 30) {
      message = '30 days to $examType! Intensify your preparation!';
    } else if (daysRemaining == 14) {
      message = '2 weeks to $examType! Enter final drill phase!';
    } else if (daysRemaining == 7) {
      message = '7 days to $examType! Mission critical phase initiated!';
    } else if (daysRemaining == 1) {
      message = 'Tomorrow is $examType! Stay calm and confident, soldier!';
    } else {
      message = '$daysRemaining days to $examType. Stay on track!';
    }

    await flutterLocalNotificationsPlugin.show(
      888888, // Fixed ID for exam countdown
      '⏰ Exam Countdown Alert',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          examChannel,
          'Exam Countdown',
          channelDescription: 'Notifications about upcoming exam milestones',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'exam:$daysRemaining',
    );
  }

  // Helper: Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
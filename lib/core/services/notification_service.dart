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
  static const String studyChannel = 'study_session_channel';
  static const String mockTestChannel = 'mock_test_channel';

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
      const AndroidNotificationChannel(
        studyChannel,
        'Study Session Reminders',
        description: 'Reminders to start your study sessions',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      const AndroidNotificationChannel(
        mockTestChannel,
        'Mock Test Reminders',
        description: 'Reminders to log your mock test results',
        importance: Importance.high,
        enableVibration: true,
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
    final scheduledDateTime = _nextInstanceOfTime(scheduledTime);
    print('🔔 Scheduling habit reminder:');
    print('   ID: $id');
    print('   Title: $title');
    print('   Scheduled for: $scheduledDateTime');
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit:$id',
    );
    
    print('   ✅ Notification scheduled successfully');
  }

  // Schedule revision topic reminder
  Future<void> scheduleRevisionReminder({
    required int id,
    required String topicName,
    required String subject,
    required DateTime dueDate,
    TimeOfDay? reminderTime,
  }) async {
    final scheduledTime = reminderTime ?? const TimeOfDay(hour: 8, minute: 0);
    
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
      print('🔔 Scheduling revision reminder:');
      print('   Topic: $topicName ($subject)');
      print('   Due: $scheduleDate');
      
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'revision:$id',
      );
      
      print('   ✅ Revision reminder scheduled successfully');
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
    final scheduledDateTime = _nextInstanceOfTime(time);
    
    print('🔔 Scheduling daily motivation:');
    print('   Scheduled for: $scheduledDateTime');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999999, // Fixed ID for daily motivation
      '💪 REVEILLE - Daily Briefing',
      message,
      scheduledDateTime,
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'motivation',
    );
    
    print('   ✅ Daily motivation scheduled successfully');
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
  
  // Debug: Print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    print('📋 Pending Notifications (${pending.length} total):');
    for (var notif in pending) {
      print('   - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
    }
    if (pending.isEmpty) {
      print('   ⚠️ No pending notifications found!');
    }
  }

  // ============================================================
  // GLOBAL NOTIFICATION SCHEDULING
  // ============================================================

  // Motivational quotes for 3-hour intervals
  static const List<String> _motivationalQuotes = [
    "🔥 Rise and grind, soldier! Your dreams won't chase themselves.",
    "💪 Discipline is doing what needs to be done, even when you don't want to.",
    "🎯 Success is the sum of small efforts, repeated day in and day out.",
    "⚔️ A warrior's greatest victory is over themselves.",
    "🚀 Push yourself, because no one else is going to do it for you.",
    "🌟 The pain you feel today is the strength you feel tomorrow.",
    "🏆 Champions are made when no one is watching.",
    "📚 Every hour of study brings you closer to your goal.",
    "💡 Your only limit is your mind. Break through!",
    "🎖️ Warriors are not those who never fail, but those who never quit.",
    "⏰ Time wasted is opportunity lost. Make every moment count!",
    "🔱 Train your mind to be stronger than your excuses.",
  ];

  /// Schedule all global notifications
  /// Call this once on app startup to set up recurring notifications
  Future<void> scheduleGlobalNotifications() async {
    print('🔔 Setting up global notifications...');
    
    // Schedule study session reminders (Morning, Afternoon, Evening)
    await _scheduleStudySessionReminders();
    
    // Schedule daily habits reminder (Morning)
    await _scheduleDailyHabitsReminder();
    
    // Schedule mock test logging reminders (Weekends)
    await _scheduleMockTestReminders();
    
    // Schedule motivational quotes every 3 hours
    await _scheduleMotivationalQuotes();
    
    print('✅ Global notifications scheduled successfully!');
    await debugPrintPendingNotifications();
  }

  /// Schedule study session reminders at 9 AM, 2 PM, and 6 PM
  Future<void> _scheduleStudySessionReminders() async {
    final studyTimes = [
      const TimeOfDay(hour: 9, minute: 0),   // Morning session
      const TimeOfDay(hour: 14, minute: 0),  // Afternoon session
      const TimeOfDay(hour: 18, minute: 0),  // Evening session
    ];

    final studyMessages = [
      '🌅 Morning Study Session: Fresh mind, best retention! Start your studies now.',
      '☀️ Afternoon Drill: Time to push through! Continue your mission.',
      '🌙 Evening Operations: Final push of the day! Finish strong.',
    ];

    for (int i = 0; i < studyTimes.length; i++) {
      final scheduledDateTime = _nextInstanceOfTime(studyTimes[i]);
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        100000 + i, // Unique IDs for study reminders: 100000, 100001, 100002
        '📖 Study Session Reminder',
        studyMessages[i],
        scheduledDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            studyChannel,
            'Study Session Reminders',
            channelDescription: 'Reminders to start your study sessions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily recurring
        payload: 'study_reminder:$i',
      );
      
      print('   📖 Study reminder ${i + 1} scheduled for ${studyTimes[i].hour}:${studyTimes[i].minute.toString().padLeft(2, '0')}');
    }
  }

  /// Schedule daily habits reminder at 7 AM
  Future<void> _scheduleDailyHabitsReminder() async {
    const habitTime = TimeOfDay(hour: 7, minute: 0);
    final scheduledDateTime = _nextInstanceOfTime(habitTime);
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      200000, // Unique ID for daily habits reminder
      '✅ Daily Directives Awaiting',
      'Good morning, soldier! Complete your daily habits to maintain discipline.',
      scheduledDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          habitChannel,
          'Directive Reminders',
          channelDescription: 'Reminders for your daily directives and habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily recurring
      payload: 'habits_reminder',
    );
    
    print('   ✅ Daily habits reminder scheduled for 07:00');
  }

  /// Schedule mock test logging reminders for weekends at 10 AM
  Future<void> _scheduleMockTestReminders() async {
    // Schedule for Saturday and Sunday at 10 AM
    final now = tz.TZDateTime.now(tz.local);
    
    // Find next Saturday
    int daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    if (daysUntilSaturday == 0 && now.hour >= 10) {
      daysUntilSaturday = 7; // If today is Saturday and past 10 AM, schedule for next Saturday
    }
    
    final nextSaturday = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilSaturday,
      10,
      0,
    );
    
    // Find next Sunday
    int daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    if (daysUntilSunday == 0 && now.hour >= 10) {
      daysUntilSunday = 7; // If today is Sunday and past 10 AM, schedule for next Sunday
    }
    
    final nextSunday = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilSunday,
      10,
      0,
    );

    // Saturday reminder
    await flutterLocalNotificationsPlugin.zonedSchedule(
      300000, // Unique ID for Saturday mock test reminder
      '📝 Mock Test Day!',
      'Weekend warrior mode activated! Take a mock test and log your results.',
      nextSaturday,
      NotificationDetails(
        android: AndroidNotificationDetails(
          mockTestChannel,
          'Mock Test Reminders',
          channelDescription: 'Reminders to log your mock test results',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Weekly recurring on Saturday
      payload: 'mock_test_saturday',
    );

    // Sunday reminder
    await flutterLocalNotificationsPlugin.zonedSchedule(
      300001, // Unique ID for Sunday mock test reminder
      '📝 Sunday Assessment!',
      'Complete a mock test today and track your progress. Stay battle-ready!',
      nextSunday,
      NotificationDetails(
        android: AndroidNotificationDetails(
          mockTestChannel,
          'Mock Test Reminders',
          channelDescription: 'Reminders to log your mock test results',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Weekly recurring on Sunday
      payload: 'mock_test_sunday',
    );
    
    print('   📝 Mock test reminders scheduled for Saturday & Sunday at 10:00');
  }

  /// Schedule motivational quotes every 3 hours (6 AM, 9 AM, 12 PM, 3 PM, 6 PM, 9 PM)
  Future<void> _scheduleMotivationalQuotes() async {
    final motivationTimes = [
      const TimeOfDay(hour: 6, minute: 0),   // Early morning
      const TimeOfDay(hour: 9, minute: 0),   // Morning
      const TimeOfDay(hour: 12, minute: 0),  // Noon
      const TimeOfDay(hour: 15, minute: 0),  // Afternoon
      const TimeOfDay(hour: 18, minute: 0),  // Evening
      const TimeOfDay(hour: 21, minute: 0),  // Night
    ];

    for (int i = 0; i < motivationTimes.length; i++) {
      final scheduledDateTime = _nextInstanceOfTime(motivationTimes[i]);
      
      // Use different quotes based on time slot and day
      final quoteIndex = (DateTime.now().day + i) % _motivationalQuotes.length;
      final quote = _motivationalQuotes[quoteIndex];
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        400000 + i, // Unique IDs for motivation quotes: 400000-400005
        '💪 Motivation Boost',
        quote,
        scheduledDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            motivationChannel,
            'Daily Motivation',
            channelDescription: 'Daily motivational messages to keep you on track',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Daily recurring
        payload: 'motivation:$i',
      );
    }
    
    print('   💪 Motivational quotes scheduled every 3 hours (6 times daily)');
  }
}
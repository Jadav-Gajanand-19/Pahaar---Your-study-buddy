import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/notification_service.dart';
import 'package:prahar/core/services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced NotificationService with Hybrid Notification Support
/// Sends critical notifications via BOTH local scheduling AND global FCM
class HybridNotificationService {
  final NotificationService _localNotifications;
  final FCMService _fcmService;
  final FirebaseFirestore _firestore;

  HybridNotificationService({
    required NotificationService localNotifications,
    required FCMService fcmService,
    required FirebaseFirestore firestore,
  })  : _localNotifications = localNotifications,
        _fcmService = fcmService,
        _firestore = firestore;

  /// Schedule habit reminder as HYBRID (local + global)
  Future<void> scheduleHabitReminderHybrid({
    required String userId,
    required int habitId,
    required String habitTitle,
    required TimeOfDay reminderTime,
  }) async {
    try {
      // 1. Schedule LOCAL notification (existing functionality)
      await _localNotifications.scheduleDailyHabitReminder(
        id: habitId,
        title: 'Directive Reminder',
        body: habitTitle,
        scheduledTime: reminderTime,
      );

      // 2. Schedule GLOBAL FCM notification (server-triggered backup)
      await _fcmService.scheduleGlobalNotification(
        userId: userId,
        type: 'habit_reminder',
        title: 'Directive Reminder',
        body: habitTitle,
        scheduledTime: '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
        recurrence: 'daily',
        additionalData: {
          'habitId': habitId,
          'screen': 'habit_tracker',
        },
      );

      print('✅ Hybrid habit reminder scheduled: Local + Global');
    } catch (e) {
      print('❌ Error scheduling hybrid habit reminder: $e');
    }
  }

  /// Schedule revision reminder as HYBRID (local + global)
  Future<void> scheduleRevisionReminderHybrid({
    required String userId,
    required String topicId,
    required String topicName,
    required String subject,
    required DateTime dueDate,
    TimeOfDay? reminderTime,
  }) async {
    try {
      final timeToSchedule = reminderTime ?? const TimeOfDay(hour: 8, minute: 0);
      
      // 1. Schedule LOCAL notification
      await _localNotifications.scheduleRevisionReminder(
        id: topicId.hashCode,
        topicName: topicName,
        subject: subject,
        dueDate: dueDate,
        reminderTime: timeToSchedule,
      );

      // 2. Schedule GLOBAL FCM notification
      await _fcmService.scheduleGlobalNotification(
        userId: userId,
        type: 'revision_reminder',
        title: 'Revision Alert: $subject',
        body: topicName,
        scheduledTime: '${timeToSchedule.hour.toString().padLeft(2, '0')}:${timeToSchedule.minute.toString().padLeft(2, '0')}',
        recurrence: 'once',
        additionalData: {
          'topicId': topicId,
          'subject': subject,
          'dueDate': dueDate.toIso8601String(),
          'screen': 'prep_screen',
        },
      );

      print('✅ Hybrid revision reminder scheduled: Local + Global');
    } catch (e) {
      print('❌ Error scheduling hybrid revision reminder: $e');
    }
  }

  /// Schedule study session reminder as HYBRID (local + global)
  Future<void> scheduleStudyReminderHybrid({
    required String userId,
    required String sessionId,
    required TimeOfDay reminderTime,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 'Time for your study session!';

      // 1. Schedule LOCAL notification
      // Note: Add this method to NotificationService if not exists
      // await _localNotifications.scheduleDailyNotification(...)

      // 2. Schedule GLOBAL FCM notification
      await _fcmService.scheduleGlobalNotification(
        userId: userId,
        type: 'study_reminder',
        title: 'Study Time',
        body: message,
        scheduledTime: '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
        recurrence: 'daily',
        additionalData: {
          'sessionId': sessionId,
          'screen': 'study_timer',
        },
      );

      print('✅ Hybrid study reminder scheduled: Local + Global');
    } catch (e) {
      print('❌ Error scheduling hybrid study reminder: $e');
    }
  }

  /// Cancel habit reminder (both local and global)
  Future<void> cancelHabitReminder({
    required String userId,
    required int habitId,
  }) async {
    try {
      // 1. Cancel local notification
      await _localNotifications.cancelNotification(habitId);

      // 2. Cancel global FCM notification
      // Query for the scheduled notification and deactivate it
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scheduledNotifications')
          .where('type', isEqualTo: 'habit_reminder')
          .where('habitId', isEqualTo: habitId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        await _fcmService.cancelScheduledNotification(userId, doc.id);
      }

      print('✅ Hybrid habit reminder cancelled: Local + Global');
    } catch (e) {
      print('❌ Error cancelling hybrid habit reminder: $e');
    }
  }
}

/// Provider for Hybrid Notification Service
final hybridNotificationServiceProvider = Provider<HybridNotificationService>((ref) {
  return HybridNotificationService(
    localNotifications: NotificationService(),
    fcmService: FCMService(),
    firestore: FirebaseFirestore.instance,
  );
});

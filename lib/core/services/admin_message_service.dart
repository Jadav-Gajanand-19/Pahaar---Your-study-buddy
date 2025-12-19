import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/data/models/global_message_model.dart';

/// Admin Message Service
/// Handles scheduling, management, and testing of global FCM notifications
/// Note: This is client-side logic for testing. For production, move to Cloud Functions.
class AdminMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Schedule a new global message
  Future<String> scheduleGlobalMessage(GlobalMessage message) async {
    try {
      final docRef = await _firestore
          .collection('globalMessages')
          .add(message.toMap());

      print('Admin: Global message scheduled with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Admin: Error scheduling global message: $e');
      rethrow;
    }
  }

  /// Update an existing global message
  Future<void> updateGlobalMessage(String messageId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('globalMessages')
          .doc(messageId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Admin: Global message $messageId updated');
    } catch (e) {
      print('Admin: Error updating global message: $e');
      rethrow;
    }
  }

  /// Cancel a scheduled global message
  Future<void> cancelGlobalMessage(String messageId) async {
    try {
      await _firestore
          .collection('globalMessages')
          .doc(messageId)
          .update({
        'isActive': false,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      print('Admin: Global message $messageId cancelled');
    } catch (e) {
      print('Admin: Error cancelling global message: $e');
      rethrow;
    }
  }

  /// Delete a global message
  Future<void> deleteGlobalMessage(String messageId) async {
    try {
      await _firestore
          .collection('globalMessages')
          .doc(messageId)
          .delete();

      print('Admin: Global message $messageId deleted');
    } catch (e) {
      print('Admin: Error deleting global message: $e');
      rethrow;
    }
  }

  /// Get all scheduled messages
  Stream<List<GlobalMessage>> watchScheduledMessages() {
    return _firestore
        .collection('globalMessages')
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GlobalMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get active messages only
  Stream<List<GlobalMessage>> watchActiveMessages() {
    return _firestore
        .collection('globalMessages')
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GlobalMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get messages by type
  Stream<List<GlobalMessage>> watchMessagesByType(String type) {
    return _firestore
        .collection('globalMessages')
        .where('type', isEqualTo: type)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GlobalMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Save a message template
  Future<String> saveMessageTemplate(MessageTemplate template) async {
    try {
      final docRef = await _firestore
          .collection('messageTemplates')
          .add(template.toMap());

      print('Admin: Message template saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Admin: Error saving message template: $e');
      rethrow;
    }
  }

  /// Get all message templates
  Stream<List<MessageTemplate>> watchMessageTemplates() {
    return _firestore
        .collection('messageTemplates')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageTemplate.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Delete a message template
  Future<void> deleteMessageTemplate(String templateId) async {
    try {
      await _firestore
          .collection('messageTemplates')
          .doc(templateId)
          .delete();

      print('Admin: Message template $templateId deleted');
    } catch (e) {
      print('Admin: Error deleting message template: $e');
      rethrow;
    }
  }

  /// Initialize default message templates
  Future<void> initializeDefaultTemplates() async {
    try {
      for (var template in MessageTemplates.defaults) {
        // Check if template already exists
        final existing = await _firestore
            .collection('messageTemplates')
            .where('id', isEqualTo: template.id)
            .get();

        if (existing.docs.isEmpty) {
          await _firestore
              .collection('messageTemplates')
              .doc(template.id)
              .set(template.toMap());
          print('Admin: Initialized template: ${template.name}');
        }
      }
    } catch (e) {
      print('Admin: Error initializing default templates: $e');
      rethrow;
    }
  }

  /// Schedule a motivational message for tomorrow at a specific time
  Future<void> scheduleDailyMotivation({
    required String message,
    required int hour,
    required int minute,
  }) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      hour,
      minute,
    );

    final globalMessage = GlobalMessage(
      id: '',
      type: 'motivation',
      title: '⚔️ REVEILLE - Mission Briefing',
      body: message,
      data: {'screen': 'dashboard'},
      scheduledTime: scheduledTime,
      recurrence: 'daily',
      targetTopics: ['all_users'],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await scheduleGlobalMessage(globalMessage);
  }

  /// Schedule an exam countdown notification
  Future<void> scheduleExamCountdown({
    required String examType,
    required DateTime examDate,
    required int daysBeforeExam,
  }) async {
    final notificationDate = examDate.subtract(Duration(days: daysBeforeExam));

    String body;
    if (daysBeforeExam == 30) {
      body = '30 days to $examType! Intensify your preparation, soldier!';
    } else if (daysBeforeExam == 14) {
      body = '2 weeks to $examType! Enter final drill phase!';
    } else if (daysBeforeExam == 7) {
      body = '7 days to $examType! Mission critical phase initiated!';
    } else if (daysBeforeExam == 1) {
      body = 'Tomorrow is $examType! Stay calm and confident, soldier!';
    } else {
      body = '$daysBeforeExam days to $examType. Stay on track!';
    }

    final globalMessage = GlobalMessage(
      id: '',
      type: 'exam_reminder',
      title: '🎯 $examType - Countdown Alert',
      body: body,
      data: {
        'screen': 'ops_calendar',
        'examType': examType,
        'daysRemaining': daysBeforeExam,
      },
      scheduledTime: DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        18, // 6 PM
        0,
      ),
      recurrence: 'once',
      targetTopics: ['all_users', '${examType.toLowerCase()}_users'],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await scheduleGlobalMessage(globalMessage);
  }

  /// Schedule a weekly tip/announcement
  Future<void> scheduleWeeklyTip({
    required String tip,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var targetDate = now;

    // Find next occurrence of the specified day of week
    while (targetDate.weekday != dayOfWeek) {
      targetDate = targetDate.add(const Duration(days: 1));
    }

    final scheduledTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );

    final globalMessage = GlobalMessage(
      id: '',
      type: 'tip',
      title: '💡 Intelligence Brief',
      body: tip,
      data: {'screen': 'dashboard'},
      scheduledTime: scheduledTime,
      recurrence: 'weekly',
      targetTopics: ['all_users'],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await scheduleGlobalMessage(globalMessage);
  }

  /// Get message statistics
  Future<Map<String, int>> getMessageStatistics() async {
    try {
      final allMessages =await _firestore.collection('globalMessages').get();
      final activeMessages = await _firestore
          .collection('globalMessages')
          .where('isActive', isEqualTo: true)
          .get();

      final byType = <String, int>{};
for (var doc in allMessages.docs) {
        final type = doc.data()['type'] as String?;
        if (type != null) {
          byType[type] = (byType[type] ?? 0) + 1;
        }
      }

      return {
        'total': allMessages.docs.length,
        'active': activeMessages.docs.length,
        'inactive': allMessages.docs.length - activeMessages.docs.length,
        ...byType,
      };
    } catch (e) {
      print('Admin: Error getting message statistics: $e');
      return {};
    }
  }
}

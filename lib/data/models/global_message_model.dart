import 'package:cloud_firestore/cloud_firestore.dart';

/// Global Message Model
/// Represents a scheduled global notification sent to multiple users via FCM
class GlobalMessage {
  final String id;
  final String type; // 'motivation', 'exam_reminder', 'announcement', 'tip'
  final String title;
  final String body;
  final Map<String, dynamic> data; // Additional data for navigation, etc.
  final DateTime scheduledTime;
  final String recurrence; // 'once', 'daily', 'weekly'
  final List<String> targetTopics; // FCM topics to send to ['all_users', 'cds_2025']
  final bool isActive;
  final String? imageUrl; // Optional image for rich notifications
  final DateTime createdAt;
  final String? createdBy; // Admin user ID who created this message

  GlobalMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.scheduledTime,
    required this.recurrence,
    required this.targetTopics,
    required this.isActive,
    this.imageUrl,
    required this.createdAt,
    this.createdBy,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'recurrence': recurrence,
      'targetTopics': targetTopics,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  /// Create from Firestore map
  factory GlobalMessage.fromMap(Map<String, dynamic> map, String documentId) {
    return GlobalMessage(
      id: documentId,
      type: map['type'] ?? 'announcement',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      recurrence: map['recurrence'] ?? 'once',
      targetTopics: List<String>.from(map['targetTopics'] ?? ['all_users']),
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'],
    );
  }

  /// Create a copy with modified values
  GlobalMessage copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? scheduledTime,
    String? recurrence,
    List<String>? targetTopics,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return GlobalMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recurrence: recurrence ?? this.recurrence,
      targetTopics: targetTopics ?? this.targetTopics,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// Message Template Model
/// Reusable templates for common notification messages
class MessageTemplate {
  final String id;
  final String name;
  final String type;
  final String titleTemplate; // Can include placeholders like {{userName}}
  final String bodyTemplate; // Can include placeholders like {{daysRemaining}}
  final Map<String, dynamic> defaultData;
  final DateTime createdAt;

  MessageTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.defaultData,
    required this.createdAt,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'titleTemplate': titleTemplate,
      'bodyTemplate': bodyTemplate,
      'defaultData': defaultData,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore map
  factory MessageTemplate.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageTemplate(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'announcement',
      titleTemplate: map['titleTemplate'] ?? '',
      bodyTemplate: map['bodyTemplate'] ?? '',
      defaultData: Map<String, dynamic>.from(map['defaultData'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Apply template with variables
  String applyVariables(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  /// Get title with applied variables
  String getTitle(Map<String, String> variables) {
    return applyVariables(titleTemplate, variables);
  }

  /// Get body with applied variables
  String getBody(Map<String, String> variables) {
    return applyVariables(bodyTemplate, variables);
  }
}

/// Predefined Message Templates
class MessageTemplates {
  static final List<MessageTemplate> defaults = [
    MessageTemplate(
      id: 'daily_motivation_1',
      name: 'Daily Motivation - Discipline',
      type: 'motivation',
      titleTemplate: '⚔️ REVEILLE - Mission Briefing',
      bodyTemplate: 'Soldier! Time to execute your mission. Every directive completed is a victory!',
      defaultData: {'screen': 'dashboard'},
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'exam_countdown_30',
      name: 'Exam Countdown - 30 Days',
      type: 'exam_reminder',
      titleTemplate: '🎯 {{examType}} - 30 Days Alert',
      bodyTemplate: '30 days to {{examType}}! Intensify your preparation, soldier!',
      defaultData: {'screen': 'ops_calendar'},
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'exam_countdown_7',
      name: 'Exam Countdown - 7 Days',
      type: 'exam_reminder',
      titleTemplate: '⚡ {{examType}} - Final Week',
      bodyTemplate: '7 days to {{examType}}! Mission critical phase initiated!',
      defaultData: {'screen': 'ops_calendar'},
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'weekly_review',
      name: 'Weekly Performance Review',
      type: 'announcement',
      titleTemplate: '📊 Weekly Intel Report Available',
      bodyTemplate: 'Review your weekly performance and adjust your strategy for the next mission!',
      defaultData: {'screen': 'weekly_operations'},
      createdAt: DateTime.now(),
    ),
    MessageTemplate(
      id: 'study_tip',
      name: 'Study Tip of the Day',
      type: 'tip',
      titleTemplate: '💡 Intelligence Brief',
      bodyTemplate: 'Pro tip: Break your study sessions into focused 25-minute blocks for maximum retention.',
      defaultData: {'screen': 'dashboard'},
      createdAt: DateTime.now(),
    ),
  ];
}

import 'package:flutter/material.dart';

/// Notification Preferences Model
/// Stores user's notification preferences for all channels
class NotificationPreferences {
  final bool habitRemindersEnabled;
  final bool revisionAlertsEnabled;
  final bool dailyMotivationEnabled;
  final bool achievementsEnabled;
  final bool examCountdownEnabled;
  final bool globalAnnouncementsEnabled;

  final TimeOfDay? habitReminderTime;
  final TimeOfDay? dailyMotivationTime;
  final List<String> subscribedTopics; // e.g., ['all_users', 'cds_2025', 'afcat_2025']

  const NotificationPreferences({
    this.habitRemindersEnabled = true,
    this.revisionAlertsEnabled = true,
    this.dailyMotivationEnabled = true,
    this.achievementsEnabled = true,
    this.examCountdownEnabled = true,
    this.globalAnnouncementsEnabled = true,
    this.habitReminderTime,
    this.dailyMotivationTime,
    this.subscribedTopics = const ['all_users'],
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'habitRemindersEnabled': habitRemindersEnabled,
      'revisionAlertsEnabled': revisionAlertsEnabled,
      'dailyMotivationEnabled': dailyMotivationEnabled,
      'achievementsEnabled': achievementsEnabled,
      'examCountdownEnabled': examCountdownEnabled,
      'globalAnnouncementsEnabled': globalAnnouncementsEnabled,
      'habitReminderTime': habitReminderTime != null
          ? '${habitReminderTime!.hour}:${habitReminderTime!.minute}'
          : null,
      'dailyMotivationTime': dailyMotivationTime != null
          ? '${dailyMotivationTime!.hour}:${dailyMotivationTime!.minute}'
          : null,
      'subscribedTopics': subscribedTopics,
    };
  }

  /// Create from Firestore map
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      habitRemindersEnabled: map['habitRemindersEnabled'] ?? true,
      revisionAlertsEnabled: map['revisionAlertsEnabled'] ?? true,
      dailyMotivationEnabled: map['dailyMotivationEnabled'] ?? true,
      achievementsEnabled: map['achievementsEnabled'] ?? true,
      examCountdownEnabled: map['examCountdownEnabled'] ?? true,
      globalAnnouncementsEnabled: map['globalAnnouncementsEnabled'] ?? true,
      habitReminderTime: map['habitReminderTime'] != null
          ? _parseTimeOfDay(map['habitReminderTime'])
          : null,
      dailyMotivationTime: map['dailyMotivationTime'] != null
          ? _parseTimeOfDay(map['dailyMotivationTime'])
          : null,
      subscribedTopics: List<String>.from(map['subscribedTopics'] ?? ['all_users']),
    );
  }

  /// Helper to parse TimeOfDay from string "HH:mm"
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Create a copy with modified values
  NotificationPreferences copyWith({
    bool? habitRemindersEnabled,
    bool? revisionAlertsEnabled,
    bool? dailyMotivationEnabled,
    bool? achievementsEnabled,
    bool? examCountdownEnabled,
    bool? globalAnnouncementsEnabled,
    TimeOfDay? habitReminderTime,
    TimeOfDay? dailyMotivationTime,
    List<String>? subscribedTopics,
  }) {
    return NotificationPreferences(
      habitRemindersEnabled: habitRemindersEnabled ?? this.habitRemindersEnabled,
      revisionAlertsEnabled: revisionAlertsEnabled ?? this.revisionAlertsEnabled,
      dailyMotivationEnabled: dailyMotivationEnabled ?? this.dailyMotivationEnabled,
      achievementsEnabled: achievementsEnabled ?? this.achievementsEnabled,
      examCountdownEnabled: examCountdownEnabled ?? this.examCountdownEnabled,
      globalAnnouncementsEnabled: globalAnnouncementsEnabled ?? this.globalAnnouncementsEnabled,
      habitReminderTime: habitReminderTime ?? this.habitReminderTime,
      dailyMotivationTime: dailyMotivationTime ?? this.dailyMotivationTime,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    );
  }

  /// Default preferences
  static const NotificationPreferences defaultPreferences = NotificationPreferences();
}

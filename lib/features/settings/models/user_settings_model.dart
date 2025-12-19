import 'package:cloud_firestore/cloud_firestore.dart';

/// User Settings Model - Personal preferences and configuration
class UserSettings {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String? email;
  final DateTime? examDate;
  final String? examType; // CDS, AFCAT, NDA, etc.
  final bool notificationsEnabled;
  final bool dailyChallengeReminders;
  final bool habitReminders;
  final bool studyReminders;
  final bool revisionReminders;
  final bool achievementNotifications;
  final String? dailyMotivationTime; // e.g., "06:00"
  final String? preferredStudyTime; // e.g., "Morning", "Evening"
  final int? dailyStudyGoalMinutes;
  final bool darkModeEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.email,
    this.examDate,
    this.examType,
    this.notificationsEnabled = true,
    this.dailyChallengeReminders = true,
    this.habitReminders = true,
    this.studyReminders = true,
    this.revisionReminders = true,
    this.achievementNotifications = true,
    this.dailyMotivationTime,
    this.preferredStudyTime,
    this.dailyStudyGoalMinutes,
    this.darkModeEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore
  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSettings(
      userId: doc.id,
      displayName: data['displayName'] ?? 'Cadet',
      photoUrl: data['photoUrl'],
      email: data['email'],
      examDate: data['examDate'] != null
          ? (data['examDate'] as Timestamp).toDate()
          : null,
      examType: data['examType'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      dailyChallengeReminders: data['dailyChallengeReminders'] ?? true,
      habitReminders: data['habitReminders'] ?? true,
      studyReminders: data['studyReminders'] ?? true,
      revisionReminders: data['revisionReminders'] ?? true,
      achievementNotifications: data['achievementNotifications'] ?? true,
      dailyMotivationTime: data['dailyMotivationTime'],
      preferredStudyTime: data['preferredStudyTime'],
      dailyStudyGoalMinutes: data['dailyStudyGoalMinutes'],
      darkModeEnabled: data['darkModeEnabled'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'examDate': examDate != null ? Timestamp.fromDate(examDate!) : null,
      'examType': examType,
      'notificationsEnabled': notificationsEnabled,
      'dailyChallengeReminders': dailyChallengeReminders,
      'habitReminders': habitReminders,
      'studyReminders': studyReminders,
      'revisionReminders': revisionReminders,
      'achievementNotifications': achievementNotifications,
      'dailyMotivationTime': dailyMotivationTime,
      'preferredStudyTime': preferredStudyTime,
      'dailyStudyGoalMinutes': dailyStudyGoalMinutes,
      'darkModeEnabled': darkModeEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method
  UserSettings copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? email,
    DateTime? examDate,
    String? examType,
    bool? notificationsEnabled,
    bool? dailyChallengeReminders,
    bool? habitReminders,
    bool? studyReminders,
    bool? revisionReminders,
    bool? achievementNotifications,
    String? dailyMotivationTime,
    String? preferredStudyTime,
    int? dailyStudyGoalMinutes,
    bool? darkModeEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      examDate: examDate ?? this.examDate,
      examType: examType ?? this.examType,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyChallengeReminders: dailyChallengeReminders ?? this.dailyChallengeReminders,
      habitReminders: habitReminders ?? this.habitReminders,
      studyReminders: studyReminders ?? this.studyReminders,
      revisionReminders: revisionReminders ?? this.revisionReminders,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
      dailyMotivationTime: dailyMotivationTime ?? this.dailyMotivationTime,
      preferredStudyTime: preferredStudyTime ?? this.preferredStudyTime,
      dailyStudyGoalMinutes: dailyStudyGoalMinutes ?? this.dailyStudyGoalMinutes,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get days until exam
  int? getDaysUntilExam() {
    if (examDate == null) return null;
    final now = DateTime.now();
    final difference = examDate!.difference(now);
    return difference.inDays;
  }

  // Check if exam date is set
  bool get hasExamDate => examDate != null;

  // Get exam type display name
  String get examTypeDisplay {
    switch (examType) {
      case 'CDS':
        return 'Combined Defence Services';
      case 'AFCAT':
        return 'Air Force Common Admission Test';
      case 'NDA':
        return 'National Defence Academy';
      case 'INET':
        return 'Indian Navy Entrance Test';
      default:
        return examType ?? 'Not Set';
    }
  }
}

/// Exam Types
enum ExamType {
  cds,
  afcat,
  nda,
  inet,
}

extension ExamTypeExtension on ExamType {
  String get displayName {
    switch (this) {
      case ExamType.cds:
        return 'CDS - Combined Defence Services';
      case ExamType.afcat:
        return 'AFCAT - Air Force Common Admission Test';
      case ExamType.nda:
        return 'NDA - National Defence Academy';
      case ExamType.inet:
        return 'INET - Indian Navy Entrance Test';
    }
  }

  String get shortName {
    switch (this) {
      case ExamType.cds:
        return 'CDS';
      case ExamType.afcat:
        return 'AFCAT';
      case ExamType.nda:
        return 'NDA';
      case ExamType.inet:
        return 'INET';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard Entry - User ranking data
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int rank;
  final int score; // XP, hours, challenges completed, etc.
  final int? level;
  final String? badge; // Top badge icon

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.rank,
    required this.score,
    this.level,
    this.badge,
  });

  // Convert from Firestore
  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data, int rank) {
    return LeaderboardEntry(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? 'Anonymous',
      photoUrl: data['photoUrl'],
      rank: rank,
      score: data['score'] ?? 0,
      level: data['level'],
      badge: data['badge'],
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'score': score,
      'level': level,
      'badge': badge,
      'updatedAt': Timestamp.now(),
    };
  }
}

/// Leaderboard Category
enum LeaderboardCategory {
  xp,           // Total XP earned
  studyHours,   // Total study hours
  challenges,   // Challenges completed
  fitness,      // Workouts completed
  streak,       // Current streak
}

/// Leaderboard Time Period
enum LeaderboardPeriod {
  weekly,
  monthly,
  allTime,
}

/// Helper methods for leaderboard categories
extension LeaderboardCategoryExtension on LeaderboardCategory {
  String get displayName {
    switch (this) {
      case LeaderboardCategory.xp:
        return 'Total XP';
      case LeaderboardCategory.studyHours:
        return 'Study Hours';
      case LeaderboardCategory.challenges:
        return 'Challenges';
      case LeaderboardCategory.fitness:
        return 'Fitness';
      case LeaderboardCategory.streak:
        return 'Streak';
    }
  }

  String get militaryName {
    switch (this) {
      case LeaderboardCategory.xp:
        return 'COMMAND RANKINGS';
      case LeaderboardCategory.studyHours:
        return 'STUDY WARRIORS';
      case LeaderboardCategory.challenges:
        return 'MISSION MASTERS';
      case LeaderboardCategory.fitness:
        return 'COMBAT ELITE';
      case LeaderboardCategory.streak:
        return 'CONSISTENCY KINGS';
    }
  }

  String get icon {
    switch (this) {
      case LeaderboardCategory.xp:
        return '⭐';
      case LeaderboardCategory.studyHours:
        return '📚';
      case LeaderboardCategory.challenges:
        return '🎯';
      case LeaderboardCategory.fitness:
        return '💪';
      case LeaderboardCategory.streak:
        return '🔥';
    }
  }

  String get unit {
    switch (this) {
      case LeaderboardCategory.xp:
        return 'XP';
      case LeaderboardCategory.studyHours:
        return 'hrs';
      case LeaderboardCategory.challenges:
        return 'completed';
      case LeaderboardCategory.fitness:
        return 'workouts';
      case LeaderboardCategory.streak:
        return 'days';
    }
  }
}

extension LeaderboardPeriodExtension on LeaderboardPeriod {
  String get displayName {
    switch (this) {
      case LeaderboardPeriod.weekly:
        return 'This Week';
      case LeaderboardPeriod.monthly:
        return 'This Month';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }

  String get militaryName {
    switch (this) {
      case LeaderboardPeriod.weekly:
        return 'WEEKLY OPERATIONS';
      case LeaderboardPeriod.monthly:
        return 'MONTHLY CAMPAIGN';
      case LeaderboardPeriod.allTime:
        return 'HALL OF FAME';
    }
  }
}

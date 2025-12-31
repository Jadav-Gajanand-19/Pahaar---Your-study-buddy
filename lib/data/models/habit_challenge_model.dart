import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for 30/60-day habit challenges
class HabitChallenge {
  final String? id;
  final String title;
  final int duration; // 30 or 60 days
  final Timestamp startDate;
  final Map<int, bool> dailyCompletions; // Day number (1-30 or 1-60) -> completion status
  final Timestamp createdAt;

  HabitChallenge({
    this.id,
    required this.title,
    required this.duration,
    required this.startDate,
    Map<int, bool>? dailyCompletions,
    required this.createdAt,
  }) : dailyCompletions = dailyCompletions ?? {};

  /// Calculate how many days have been completed
  int get completedDays {
    return dailyCompletions.values.where((completed) => completed).length;
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (duration == 0) return 0.0;
    return (completedDays / duration) * 100;
  }

  /// Get the current day number based on today's date (1-indexed)
  /// Calculates based on calendar days, incrementing at 12:00 AM midnight
  int getCurrentDayNumber() {
    final now = DateTime.now();
    final start = startDate.toDate();
    
    // Normalize both to midnight to count calendar days correctly
    final startDateMidnight = DateTime(start.year, start.month, start.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    
    final difference = nowMidnight.difference(startDateMidnight).inDays + 1; // +1 to make it 1-indexed
    return difference.clamp(1, duration);
  }

  /// Check if the challenge is still active
  bool get isActive {
    final now = DateTime.now();
    final start = startDate.toDate();
    final end = start.add(Duration(days: duration));
    return now.isBefore(end) && now.isAfter(start.subtract(const Duration(days: 1)));
  }

  /// Check if the challenge is completed
  bool get isCompleted {
    final now = DateTime.now();
    final start = startDate.toDate();
    final end = start.add(Duration(days: duration));
    return now.isAfter(end) || completedDays == duration;
  }

  factory HabitChallenge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    // Parse dailyCompletions from Firestore (stored as Map<String, dynamic>)
    final Map<int, bool> completions = {};
    final rawCompletions = data['dailyCompletions'] as Map<String, dynamic>? ?? {};
    rawCompletions.forEach((key, value) {
      completions[int.parse(key)] = value as bool;
    });

    return HabitChallenge(
      id: snapshot.id,
      title: data['title'] as String? ?? '',
      duration: data['duration'] as int? ?? 30,
      startDate: data['startDate'] as Timestamp? ?? Timestamp.now(),
      dailyCompletions: completions,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert Map<int, bool> to Map<String, dynamic> for Firestore
    final Map<String, dynamic> completionsForFirestore = {};
    dailyCompletions.forEach((key, value) {
      completionsForFirestore[key.toString()] = value;
    });

    return {
      'title': title,
      'duration': duration,
      'startDate': startDate,
      'dailyCompletions': completionsForFirestore,
      'createdAt': createdAt,
    };
  }
}

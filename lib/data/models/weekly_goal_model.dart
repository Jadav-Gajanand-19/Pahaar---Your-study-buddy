import 'package:cloud_firestore/cloud_firestore.dart';

/// Goal Type - Single completion or Daily completion
enum GoalType {
  single,  // Complete once during the week
  daily,   // Complete on each day of the week
}

class WeeklyGoal {
  final String? id;
  final String title;
  final String category;
  final bool isCompleted; // For single tasks only
  final GoalType goalType;
  final Map<int, bool> dailyCompletions; // For daily tasks: {0: true, 1: false, ...} where 0=Sunday
  final String weekId; // e.g., "2025-41" for the 41st week of 2025
  final Timestamp createdAt;

  WeeklyGoal({
    this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.goalType = GoalType.single,
    this.dailyCompletions = const {},
    required this.weekId,
    required this.createdAt,
  });

  factory WeeklyGoal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    
    // Parse goal type
    GoalType type = GoalType.single;
    if (data['goalType'] != null) {
      type = data['goalType'] == 'daily' ? GoalType.daily : GoalType.single;
    }
    
    // Parse daily completions
    Map<int, bool> completions = {};
    if (data['dailyCompletions'] != null) {
      final rawMap = data['dailyCompletions'] as Map<String, dynamic>;
      completions = rawMap.map((key, value) => MapEntry(int.parse(key), value as bool));
    }
    
    return WeeklyGoal(
      id: snapshot.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'General',
      isCompleted: data['isCompleted'] ?? false,
      goalType: type,
      dailyCompletions: completions,
      weekId: data['weekId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert dailyCompletions map to string keys for Firestore
    final completionsMap = dailyCompletions.map((key, value) => MapEntry(key.toString(), value));
    
    return {
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'goalType': goalType == GoalType.daily ? 'daily' : 'single',
      'dailyCompletions': completionsMap,
      'weekId': weekId,
      'createdAt': createdAt,
    };
  }

  /// Check if a specific day is completed (for daily goals)
  bool isDayCompleted(int dayOfWeek) {
    return dailyCompletions[dayOfWeek] ?? false;
  }

  /// Get completion progress (0.0 to 1.0)
  double getCompletionProgress() {
    if (goalType == GoalType.single) {
      return isCompleted ? 1.0 : 0.0;
    } else {
      // Daily goal: count completed days
      final completedDays = dailyCompletions.values.where((v) => v).length;
      return completedDays / 7.0;
    }
  }

  /// Check if today can be marked (for daily goals)
  bool canMarkToday() {
    if (goalType == GoalType.single) return false;
    
    final now = DateTime.now();
    final dayOfWeek = now.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    
    // Can only mark today
    return true; // The UI will handle the locking logic
  }

  /// Get the day of week for a given date (0 = Sunday)
  static int getDayOfWeek(DateTime date) {
    return date.weekday % 7;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  /// Check if a date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  /// Get completed days count (for daily goals)
  int getCompletedDaysCount() {
    return dailyCompletions.values.where((v) => v).length;
  }

  /// Check if goal is fully completed
  bool isFullyCompleted() {
    if (goalType == GoalType.single) {
      return isCompleted;
    } else {
      return getCompletedDaysCount() == 7;
    }
  }

  /// Create a copy with updated fields
  WeeklyGoal copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    GoalType? goalType,
    Map<int, bool>? dailyCompletions,
    String? weekId,
    Timestamp? createdAt,
  }) {
    return WeeklyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      goalType: goalType ?? this.goalType,
      dailyCompletions: dailyCompletions ?? this.dailyCompletions,
      weekId: weekId ?? this.weekId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

int calculateStreak(List<Timestamp> timestamps) {
  if (timestamps.isEmpty) return 0;

  // Convert timestamps to DateTimes and remove duplicates for the same day
  final List<DateTime> uniqueDates = timestamps
      .map((ts) => DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day))
      .toSet()
      .toList()
      .cast<DateTime>();

  // Sort dates in descending order
  uniqueDates.sort((DateTime a, DateTime b) => b.compareTo(a));

  int streak = 0;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterdayDate = todayDate.subtract(const Duration(days: 1));

  // Check if the latest log is today or yesterday
  if (uniqueDates.first.isAtSameMomentAs(todayDate) || uniqueDates.first.isAtSameMomentAs(yesterdayDate)) {
    streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final difference = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break; // Streak is broken
      }
    }
  }

  return streak;
}
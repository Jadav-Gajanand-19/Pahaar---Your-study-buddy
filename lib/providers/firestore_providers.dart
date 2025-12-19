import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/data/models/calendar_event_model.dart';
import 'package:prahar/data/models/habit_model.dart';
import 'package:prahar/data/models/journal_entry_model.dart';
import 'package:prahar/data/models/mock_test_model.dart';
import 'package:prahar/data/models/revision_topic_model.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/data/models/task_model.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/features/fitness/models/workout_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/midnight_refresh_provider.dart';

enum StatsDateRange { week, month }
final statsDateRangeProvider = StateProvider<StatsDateRange>((ref) => StatsDateRange.week);

(DateTime, DateTime) _getWeekDateRange() {
  final now = DateTime.now();
  final daysToSubtract = now.weekday % 7;
  final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  return (startOfWeek, endOfWeek);
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getUncompletedTasks(user.uid);
});

final todaysSessionsStreamProvider = StreamProvider<List<StudySession>>((ref) {
  // Watch current date to refresh at midnight
  ref.watch(currentDateProvider);
  
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getTodaysStudySessions(user.uid);
});

final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getHabits(user.uid);
});

final todaysHabitLogsProvider = StreamProvider<Map<String, DocumentSnapshot>>((ref) {
  // Watch current date to refresh at midnight
  ref.watch(currentDateProvider);
  
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value({});
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return ref.watch(firestoreServiceProvider).getHabitLogsForDateRange(user.uid, start, end).map((docs) {
    return {for (var doc in docs) (doc.data()! as Map<String, dynamic>)['habitId'] as String: doc};
  });
});

final habitCategoryFilterProvider = StateProvider<String>((ref) => 'All');

final mockTestsProvider = StreamProvider<List<MockTest>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getMockTests(user.uid);
});

final revisionTopicsProvider = StreamProvider<List<RevisionTopic>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getRevisionTopics(user.uid);
});

final journalEntriesStreamProvider = StreamProvider<List<JournalEntry>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getJournalEntries(user.uid);
});

final calendarEventsStreamProvider = StreamProvider.autoDispose.family<List<CalendarEvent>, DateTime>((ref, month) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getEventsForMonth(user.uid, month);
});

// Fitness Tracker Providers
final workoutsStreamProvider = StreamProvider<List<WorkoutModel>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getWorkouts(user.uid);
});

final todaysWorkoutsStreamProvider = StreamProvider<List<WorkoutModel>>((ref) {
  // Watch current date to refresh at midnight
  ref.watch(currentDateProvider);
  
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getTodaysWorkouts(user.uid);
});

final weeklyGoalsProvider = StreamProvider<List<WeeklyGoal>>((ref) {
  // Watch current date to detect new week at midnight
  ref.watch(currentDateProvider);
  
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getGoalsForCurrentWeek(user.uid);
});

// --- STATS PROVIDERS ---
final sessionsForStatsProvider = StreamProvider<List<StudySession>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  final range = ref.watch(statsDateRangeProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final now = DateTime.now();
  if (range == StatsDateRange.week) {
    final (start, end) = _getWeekDateRange();
    return firestoreService.getSessionsForDateRange(user.uid, start, end);
  } else {
    return firestoreService.getSessionsForMonth(user.uid, now);
  }
});

final habitLogsForStatsProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  final range = ref.watch(statsDateRangeProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final now = DateTime.now();
  DateTime start;
  DateTime end;
  if (range == StatsDateRange.week) {
    (start, end) = _getWeekDateRange();
  } else {
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 1);
  }
  return firestoreService.getHabitLogsForDateRange(user.uid, start, end);
});

final tasksForStatsProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  final range = ref.watch(statsDateRangeProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final now = DateTime.now();
  DateTime start;
  DateTime end;
  if (range == StatsDateRange.week) {
    (start, end) = _getWeekDateRange();
  } else {
    start = DateTime(now.year, now.month, 1);
    end = DateTime(now.year, now.month + 1, 1);
  }
  return firestoreService.getTasksForDateRange(user.uid, start, end);
});

// --- Ops Calendar Providers ---
final focusedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  final focusedDate = ref.watch(focusedDateProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getEventsForMonth(user.uid, focusedDate);
});

// --- NEW: Study History Providers ---
final studyHistoryFocusedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final studySessionsForMonthProvider = StreamProvider<List<StudySession>>((ref) {
  final user = ref.watch(authStateChangeProvider).value;
  final focusedMonth = ref.watch(studyHistoryFocusedMonthProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getSessionsForMonth(user.uid, focusedMonth);
});

// --- Calendar-specific Providers ---
// Provider for events in a specific month
final eventsForMonthProvider = StreamProvider.family<List<CalendarEvent>, ({String userId, DateTime month})>((ref, params) {
  return ref.watch(firestoreServiceProvider).getEventsForMonth(params.userId, params.month);
});

// Provider for study sessions in a date range
final studySessionsForDateRangeProvider = StreamProvider.family<List<StudySession>, ({String userId, DateTime start, DateTime end})>((ref, params) {
  return ref.watch(firestoreServiceProvider).getSessionsForDateRange(params.userId, params.start, params.end);
});

// Provider for workouts in a date range
final workoutsForDateRangeProvider = StreamProvider.family<List<WorkoutModel>, ({String userId, DateTime start, DateTime end})>((ref, params) {
  return ref.watch(firestoreServiceProvider).getWorkoutsForDateRange(params.userId, params.start, params.end);
});

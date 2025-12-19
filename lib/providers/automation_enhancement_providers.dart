import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/weekly_report_service.dart';
import 'package:prahar/core/services/workout_plan_generator_service.dart';
import 'package:prahar/core/services/readiness_calculator_service.dart';
import 'package:prahar/providers/firestore_providers.dart';

/// Weekly Report Service Provider
final weeklyReportServiceProvider = Provider<WeeklyReportService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return WeeklyReportService(firestoreService);
});

/// Workout Plan Generator Provider
final workoutPlanGeneratorProvider = Provider<WorkoutPlanGeneratorService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return WorkoutPlanGeneratorService(firestoreService);
});

/// Readiness Calculator Provider
final readinessCalculatorProvider = Provider<ReadinessCalculatorService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ReadinessCalculatorService(firestoreService);
});

/// Current Week Report Provider - Reactive to study and workout changes
final currentWeekReportProvider = StreamProvider.family<WeeklyReport, String>((ref, userId) {
  // Watch both study sessions and workouts streams to trigger updates
  final firestoreService = ref.watch(firestoreServiceProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  
  // Combine study sessions and workouts streams
  return firestoreService.getSessionsForDateRange(userId, weekStart, weekEnd).asyncMap((sessions) async {
    // When study sessions change, also fetch workouts and regenerate report
    final service = ref.read(weeklyReportServiceProvider);
    return await service.generateReport(userId, weekStart);
  });
});

/// User Workout Plan Provider
final userWorkoutPlanProvider = FutureProvider.family<WorkoutPlan, String>((ref, userId) async {
  final service = ref.watch(workoutPlanGeneratorProvider);
  return service.generatePlan(userId);
});

/// Exam Readiness Provider
final examReadinessProvider = FutureProvider.family<ReadinessScore, ({String userId, DateTime examDate})>((ref, params) async {
  final service = ref.watch(readinessCalculatorProvider);
  return service.calculateReadiness(params.userId, params.examDate);
});

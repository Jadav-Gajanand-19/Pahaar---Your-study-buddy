import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/core/services/database_integration_service.dart';
import 'package:prahar/data/models/integration_models.dart';

/// Weekly Aggregation Service - Automatically calculates weekly statistics
class WeeklyAggregationService {
  final FirestoreService _firestoreService;
  final DatabaseIntegrationService _dbIntegration;

  WeeklyAggregationService(this._firestoreService, this._dbIntegration);

  /// Generate and save weekly aggregate for a specific week
  Future<void> generateWeeklyAggregate(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      // Fetch all data for the week
      final studySessions = await _firestoreService
          .getSessionsForDateRangeOnce(userId, weekStart, weekEnd)
          .timeout(const Duration(seconds: 5), onTimeout: () => []);
      
      // TODO: Fetch quiz sessions, workouts, habits when methods are available
      
      // Calculate totals
      final totalStudyMinutes = studySessions.fold<int>(
        0,
        (sum, session) => sum + (session.durationInSeconds / 60).floor(),
      );
      
      // Calculate XP earned this week
      final xpTransactions = await _dbIntegration
          .getXPTransactions(userId)
          .first
          .timeout(const Duration(seconds: 10), onTimeout: () => []);
      
      final weekXP = xpTransactions
          .where((tx) => 
              tx.awardedAt.isAfter(weekStart) && 
              tx.awardedAt.isBefore(weekEnd))
          .fold<int>(0, (sum, tx) => sum + tx.amount);
      
      // Create aggregate
      final aggregate = WeeklyAggregate(
        userId: userId,
        weekStart: weekStart,
        weekEnd: weekEnd,
        totalStudyMinutes: totalStudyMinutes,
        totalWorkouts: 0, // TODO: Calculate from workouts
        quizzesTaken: 0, // TODO: Calculate from quizzes
        averageQuizScore: 0.0, // TODO: Calculate from quizzes
        habitsCompletionRate: 0.0, // TODO: Calculate from habits
        xpEarned: weekXP,
        challengesCompleted: 0, // TODO: Calculate from challenges
        generatedAt: DateTime.now(),
      );
      
      // Save to database
      await _dbIntegration.saveWeeklyAggregate(aggregate);
      
      print('✅ Generated weekly aggregate for week starting ${weekStart.toIso8601String()}');
    } catch (e) {
      print('❌ Error generating weekly aggregate: $e');
      rethrow;
    }
  }

  /// Generate aggregates for current week
  Future<void> generateCurrentWeekAggregate(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    await generateWeeklyAggregate(userId, weekStartDate);
  }

  /// Auto-generate aggregates for all past weeks (migration helper)
  Future<void> generateHistoricalAggregates(String userId, {int weeksBack = 12}) async {
    print('🔄 Generating historical aggregates for $weeksBack weeks...');
    
    final now = DateTime.now();
    for (int i = 0; i < weeksBack; i++) {
      final weekOffset = now.subtract(Duration(days: (now.weekday - 1) + (i * 7)));
      final weekStart = DateTime(weekOffset.year, weekOffset.month, weekOffset.day);
      
      try {
        await generateWeeklyAggregate(userId, weekStart);
      } catch (e) {
        print('Error generating aggregate for week $i: $e');
        // Continue with next week
      }
    }
    
    print('✅ Historical aggregates generation complete');
  }
}

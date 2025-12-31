import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/data/models/mock_test_model.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/features/fitness/models/workout_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Models for Analytics

class MockTestAnalytics {
  final int totalTests;
  final double averageScore;
  final Map<String, SubjectScore> subjectScores;
  final String? bestSubject;
  final String? worstSubject;
  final List<MockTest> recentTests;

  MockTestAnalytics({
    required this.totalTests,
    required this.averageScore,
    required this.subjectScores,
    this.bestSubject,
    this.worstSubject,
    required this.recentTests,
  });
}

class SubjectScore {
  final String subject;
  final double averageScore;
  final double improvement; // Compared to previous period
  final int testsCount;

  SubjectScore({
    required this.subject,
    required this.averageScore,
    required this.improvement,
    required this.testsCount,
  });
}

class WeekPerformance {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int habitStreakDays;
  final double challengesProgress;
  final double goalsCompletion;
  final int studyHours;
  final int workouts;
  final int xpEarned;
  final double overallScore;

  WeekPerformance({
    required this.weekStart,
    required this.weekEnd,
    required this.habitStreakDays,
    required this.challengesProgress,
    required this.goalsCompletion,
    required this.studyHours,
    required this.workouts,
    required this.xpEarned,
    required this.overallScore,
  });
}

class WeekComparison {
  final WeekPerformance currentWeek;
  final WeekPerformance previousWeek;
  final Map<String, double> percentChanges;
  final bool isImprovement;

  WeekComparison({
    required this.currentWeek,
    required this.previousWeek,
    required this.percentChanges,
    required this.isImprovement,
  });
}

class MonthAnalytics {
  final DateTime month;
  final int totalStudyHours;
  final int mockTestsCompleted;
  final double habitCompletionRate;
  final int totalWorkouts;
  final int xpEarned;
  final int achievementsUnlocked;
  final Map<String, double> studyDistribution;
  final List<int> weeklyStudyHours; // 4-5 weeks

  MonthAnalytics({
    required this.month,
    required this.totalStudyHours,
    required this.mockTestsCompleted,
    required this.habitCompletionRate,
    required this.totalWorkouts,
    required this.xpEarned,
    required this.achievementsUnlocked,
    required this.studyDistribution,
    required this.weeklyStudyHours,
  });
}

class StudyTimeDistribution {
  final Map<String, double> subjectHours;
  final String topSubject;
  final List<int> hourlyDistribution; // 24 hours

  StudyTimeDistribution({
    required this.subjectHours,
    required this.topSubject,
    required this.hourlyDistribution,
  });
}

/// Analytics Service
class AnalyticsService {
  final FirestoreService _firestoreService;

  AnalyticsService(this._firestoreService);

  // Mock Test Analytics
  Future<MockTestAnalytics> getMockTestAnalytics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final tests = await _firestoreService.getMockTests(userId)
        .first
        .timeout(const Duration(seconds: 10), onTimeout: () => []);
    
    // Filter tests in date range
    final filteredTests = tests.where((test) {
      final testDate = test.date.toDate();
      return testDate.isAfter(startDate) && testDate.isBefore(endDate);
    }).toList();

    if (filteredTests.isEmpty) {
      return MockTestAnalytics(
        totalTests: 0,
        averageScore: 0,
        subjectScores: {},
        recentTests: [],
      );
    }

    // Calculate subject-wise scores
    final Map<String, List<double>> subjectScoresMap = {};
    for (final test in filteredTests) {
      final subject = test.subject;
      if (!subjectScoresMap.containsKey(subject)) {
        subjectScoresMap[subject] = [];
      }
      // Calculate percentage from finalScore and totalMarks
      final percentage = (test.finalScore / test.totalMarks) * 100;
      subjectScoresMap[subject]!.add(percentage);
    }

    // Create subject score objects
    final Map<String, SubjectScore> subjectScores = {};
    for (final entry in subjectScoresMap.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      subjectScores[entry.key] = SubjectScore(
        subject: entry.key,
        averageScore: avg,
        improvement: 0, // TODO: Calculate vs previous period
        testsCount: entry.value.length,
      );
    }

    // Find best and worst subjects
    String? best, worst;
    double bestScore = 0, worstScore = 100;
    subjectScores.forEach((subject, score) {
      if (score.averageScore > bestScore) {
        best = subject;
        bestScore = score.averageScore;
      }
      if (score.averageScore < worstScore) {
        worst = subject;
        worstScore = score.averageScore;
      }
    });

    final avgScore = filteredTests
        .map((t) => (t.finalScore / t.totalMarks) * 100)
        .reduce((a, b) => a + b) / filteredTests.length;

    return MockTestAnalytics(
      totalTests: filteredTests.length,
      averageScore: avgScore,
      subjectScores: subjectScores,
      bestSubject: best,
      worstSubject: worst,
      recentTests: filteredTests.take(5).toList(),
    );
  }

  // Week Performance
  Future<WeekPerformance> getWeekPerformance(
    String userId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Get study sessions
    final sessions = await _firestoreService
        .getSessionsForDateRangeOnce(userId, weekStart, weekEnd)
        .timeout(const Duration(seconds: 5), onTimeout: () => []);
    final studyHours = sessions.fold<int>(
      0,
      (sum, session) => sum + (session.durationInSeconds ~/ 3600),
    );

    // Get workouts
    final workouts = await _firestoreService
        .getWorkoutsForDateRangeOnce(userId, weekStart, weekEnd)
        .timeout(const Duration(seconds: 5), onTimeout: () => []);

    // Get habit logs for streak calculation
    final habitLogs = await _firestoreService
        .getHabitLogsForDateRange(userId, weekStart, weekEnd)
        .first
        .timeout(const Duration(seconds: 10), onTimeout: () => []);
    
    // Calculate unique days with habit completions
    final uniqueDays = <String>{};
    for (final log in habitLogs) {
      final data = log.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        uniqueDays.add('${date.year}-${date.month}-${date.day}');
      }
    }

    // Calculate overall performance score (0-100)
    final score = _calculatePerformanceScore(
      studyHours,
      workouts.length,
      uniqueDays.length,
    );

    return WeekPerformance(
      weekStart: weekStart,
      weekEnd: weekEnd,
      habitStreakDays: uniqueDays.length,
      challengesProgress: 0, // TODO: Calculate from habit challenges
      goalsCompletion: 0, // TODO: Calculate from weekly goals
      studyHours: studyHours,
      workouts: workouts.length,
      xpEarned: studyHours * 10, // Rough estimate
      overallScore: score,
    );
  }

  Future<WeekComparison> compareWeeks(
    String userId,
    DateTime currentWeekStart,
  ) async {
    final current = await getWeekPerformance(userId, currentWeekStart);
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previous = await getWeekPerformance(userId, previousWeekStart);

    final changes = <String, double>{
      'habitStreak': _percentChange(
        previous.habitStreakDays.toDouble(),
        current.habitStreakDays.toDouble(),
      ),
      'studyHours': _percentChange(
        previous.studyHours.toDouble(),
        current.studyHours.toDouble(),
      ),
      'workouts': _percentChange(
        previous.workouts.toDouble(),
        current.workouts.toDouble(),
      ),
    };

    final isImprovement = current.overallScore > previous.overallScore;

    return WeekComparison(
      currentWeek: current,
      previousWeek: previous,
      percentChanges: changes,
      isImprovement: isImprovement,
    );
  }

  Future<WeekPerformance?> getBestWeek(String userId) async {
    // Get last 12 weeks
    final now = DateTime.now();
    WeekPerformance? bestWeek;
    double bestScore = 0;

    for (int i = 0; i < 12; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final week = await getWeekPerformance(userId, weekStart);
      
      if (week.overallScore > bestScore) {
        bestScore = week.overallScore;
        bestWeek = week;
      }
    }

    return bestWeek;
  }

  // Month Analytics
  Future<MonthAnalytics> getMonthAnalytics(
    String userId,
    DateTime month,
  ) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);

    // Get study sessions
    final sessions = await _firestoreService
        .getSessionsForMonthOnce(userId, month)
        .timeout(const Duration(seconds: 5), onTimeout: () => []);
    
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + (s.durationInSeconds ~/ 60),
    );

    // Subject distribution
    final Map<String, double> distribution = {};
    for (final session in sessions) {
      final subject = session.subject;
      final hours = session.durationInSeconds / 3600;
      distribution[subject] = (distribution[subject] ?? 0) + hours;
    }

    // Get mock tests
    final tests = await _firestoreService.getMockTests(userId)
        .first
        .timeout(const Duration(seconds: 10), onTimeout: () => []);
    final monthTests = tests.where((t) {
      final testDate = t.date.toDate();
      return testDate.isAfter(monthStart) && testDate.isBefore(monthEnd);
    }).length;

    // Get workouts
   final workouts = await _firestoreService
        .getWorkoutsForDateRangeOnce(userId, monthStart, monthEnd)
        .timeout(const Duration(seconds: 5), onTimeout: () => []);

    return MonthAnalytics(
      month: month,
      totalStudyHours: totalMinutes ~/ 60,
      mockTestsCompleted: monthTests,
      habitCompletionRate: 0, // TODO
      totalWorkouts: workouts.length,
      xpEarned: (totalMinutes ~/ 30) * 10,
      achievementsUnlocked: 0, // TODO
      studyDistribution: distribution,
      weeklyStudyHours: [], // TODO
    );
  }

  // Helper methods
  double _percentChange(double old, double current) {
    if (old == 0) return current > 0 ? 100 : 0;
    return ((current - old) / old) * 100;
  }

  double _calculatePerformanceScore(int studyHours, int workouts, int habitDays) {
    // 0-100 score based on targets
    final studyScore = min((studyHours / 15) * 40, 40.0); // Max 40 for 15+ hours
    final workoutScore = min((workouts / 4) * 30, 30.0); // Max 30 for 4+ workouts
    final habitScore = min((habitDays / 7) * 30, 30.0); // Max 30 for 7 days
    
    return studyScore + workoutScore + habitScore;
  }
}

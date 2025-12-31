import 'package:prahar/data/datasources/firestore_service.dart';

/// Weekly Performance Report Service
/// Generates comprehensive weekly performance summaries
class WeeklyReportService {
  final FirestoreService _firestoreService;

  WeeklyReportService(this._firestoreService);

  /// Generate weekly performance report for a user
  Future<WeeklyReport> generateReport(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      // Aggregate study data
      final studyData = await _aggregateStudyData(userId, weekStart, weekEnd);
      
      // Aggregate fitness data
      final fitnessData = await _aggregateFitnessData(userId, weekStart, weekEnd);
      
      // Aggregate habit data
      final habitData = await _aggregateHabitData(userId, weekStart, weekEnd);
      
      // Calculate overall performance score
      final performanceScore = _calculatePerformanceScore(studyData, fitnessData, habitData);
      
      return WeeklyReport(
        userId: userId,
        weekStart: weekStart,
        weekEnd: weekEnd,
        totalStudyMinutes: studyData['totalMinutes'] ?? 0,
        totalWorkouts: fitnessData['count'] ?? 0,
        habitsCompletionRate: habitData['completionRate'] ?? 0.0,
        performanceScore: performanceScore,
        xpEarned: studyData['xp'] ?? 0,
        topSubject: studyData['topSubject'] ?? 'N/A',
        insights: _generateInsights(studyData, fitnessData, habitData),
      );
    } catch (e) {
      print('Error generating weekly report: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _aggregateStudyData(String userId, DateTime start, DateTime end) async {
    try {
      final sessions = await _firestoreService.getSessionsForDateRangeOnce(userId, start, end).timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );
      
      final totalMinutes = sessions.fold<int>(0, (sum, session) => 
        sum + (session.durationInSeconds / 60).floor()
      );
      
      return {
        'totalMinutes': totalMinutes,
        'sessionCount': sessions.length,
        'xp': (totalMinutes / 30 * 10).floor(),
        'topSubject': sessions.isNotEmpty ? sessions.first.subject : 'General Studies',
      };
    } catch (e) {
      return {'totalMinutes': 0, 'sessionCount': 0, 'xp': 0};
    }
  }

  Future<Map<String, dynamic>> _aggregateFitnessData(String userId, DateTime start, DateTime end) async {
    try {
      final workouts = await _firestoreService.getWorkoutsForDateRangeOnce(userId, start, end).timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );return {'count': workouts.length};
    } catch (e) {
      return {'count': 0};
    }
  }

  Future<Map<String, dynamic>> _aggregateHabitData(String userId, DateTime start, DateTime end) async {
    try {
      // TODO: Calculate habit completion rate
      return {'completionRate': 0.0};
    } catch (e) {
      return {'completionRate': 0.0};
    }
  }

  int _calculatePerformanceScore(Map<String, dynamic> study, Map<String, dynamic> fitness, Map<String, dynamic> habit) {
    // Simple scoring: 0-100
    final studyScore = ((study['totalMinutes'] ?? 0) / 180 * 40).clamp(0, 40); // Max 40 points for 3+ hours
    final fitnessScore = ((fitness['count'] ?? 0) / 3 * 30).clamp(0, 30); // Max 30 points for 3+ workouts
    final habitScore = ((habit['completionRate'] ?? 0) * 30); // Max 30 points for 100% completion
    
    return (studyScore + fitnessScore + habitScore).toInt();
  }

  List<String> _generateInsights(Map<String, dynamic> study, Map<String, dynamic> fitness, Map<String, dynamic> habit) {
    final insights = <String>[];
    
    final studyMinutes = study['totalMinutes'] ?? 0;
    if (studyMinutes > 300) {
      insights.add('🎯 Excellent study dedication this week!');
    } else if (studyMinutes < 120) {
      insights.add('⚠️ Study time below target. Aim for 3+ hours weekly.');
    }
    
    final workoutCount = fitness['count'] ?? 0;
    if (workoutCount >= 3) {
      insights.add('💪 Great fitness consistency!');
    } else {
      insights.add('📈 Try to complete 3+ workouts per week for SSB readiness.');
    }
    
    return insights;
  }
}

/// Weekly Report Model
class WeeklyReport {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalStudyMinutes;
  final int totalWorkouts;
  final double habitsCompletionRate;
  final int performanceScore; // 0-100
  final int xpEarned;
  final String topSubject;
  final List<String> insights;

  WeeklyReport({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalStudyMinutes,
    required this.totalWorkouts,
    required this.habitsCompletionRate,
    required this.performanceScore,
    required this.xpEarned,
    required this.topSubject,
    required this.insights,
  });

  String get performanceGrade {
    if (performanceScore >= 80) return 'A';
    if (performanceScore >= 60) return 'B';
    if (performanceScore >= 40) return 'C';
    return 'D';
  }
}

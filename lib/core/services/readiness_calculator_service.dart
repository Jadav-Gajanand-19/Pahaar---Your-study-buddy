import 'package:prahar/data/datasources/firestore_service.dart';

/// Exam Readiness Predictor Service
/// Calculates overall exam readiness based on multiple factors
class ReadinessCalculatorService {
  final FirestoreService _firestoreService;

  ReadinessCalculatorService(this._firestoreService);

  /// Calculate overall exam readiness score (0-100%)
  Future<ReadinessScore> calculateReadiness(
    String userId,
    DateTime examDate,
  ) async {
    try {
      // Calculate individual component scores
      final studyScore = await _calculateStudyReadiness(userId, examDate);
      final quizScore = await _calculateQuizReadiness(userId);
      final fitnessScore = await _calculateFitnessReadiness(userId);
      final timeScore = _calculateTimeReadiness(examDate);
      
      // Weighted average
      final overallScore = (
        studyScore * 0.35 +
        quizScore * 0.30 +
        fitnessScore * 0.20 +
        timeScore * 0.15
      ).toInt();
      
      return ReadinessScore(
        overall: overallScore,
        studyReadiness: studyScore,
        knowledgeReadiness: quizScore,
        fitnessReadiness: fitnessScore,
        timeReadiness: timeScore,
        examDate: examDate,
        recommendations: _generateRecommendations(studyScore, quizScore, fitnessScore, timeScore),
      );
    } catch (e) {
      print('Error calculating readiness: $e');
      return ReadinessScore(
        overall: 0,
        studyReadiness: 0,
        knowledgeReadiness: 0,
        fitnessReadiness: 0,
        timeReadiness: 0,
        examDate: examDate,
        recommendations: ['Complete initial assessment to get readiness score'],
      );
    }
  }

  /// Calculate study coverage readiness (0-100)
  Future<int> _calculateStudyReadiness(String userId, DateTime examDate) async {
    try {
      final daysUntilExam = examDate.difference(DateTime.now()).inDays;
      final weeksRemaining = (daysUntilExam / 7).ceil();
      
      // Get total study hours
      final sessions = await _firestoreService.getSessionsForDateRange(
        userId,
        DateTime.now().subtract(const Duration(days: 90)),
        DateTime.now(),
      ).first;
      
      final totalHours = sessions.fold<int>(0, (sum, session) => 
        sum + (session.durationInSeconds / 3600).floor()
      );
      
      // Target: 5 hours/week
      final targetHours = weeksRemaining * 5;
      final score = ((totalHours / targetHours) * 100).clamp(0, 100).toInt();
      
      return score;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate quiz performance readiness (0-100)
  Future<int> _calculateQuizReadiness(String userId) async {
    // TODO: Fetch quiz results and calculate average accuracy
    // For now, return default
    return  50; // Placeholder
  }

  /// Calculate fitness readiness (0-100)
  Future<int> _calculateFitnessReadiness(String userId) async {
    // TODO: Compare current fitness to SSB standards
    return 50; // Placeholder
  }

  /// Calculate time readiness (0-100)
  int _calculateTimeReadiness(DateTime examDate) {
    final daysUntilExam = examDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExam < 0) return 0; // Exam passed
    if (daysUntilExam > 180) return 100; // Plenty of time
    if (daysUntilExam > 90) return 80;
    if (daysUntilExam > 60) return 60;
    if (daysUntilExam > 30) return 40;
    return 20; // Time running out
  }

  List<String> _generateRecommendations(int study, int quiz, int fitness, int time) {
    final recommendations = <String>[];
    
    if (study < 50) recommendations.add('📚 Increase daily study time');
    if (quiz < 50) recommendations.add('🎯 Practice more quizzes');
    if (fitness < 50) recommendations.add('💪 Intensify fitness training');
    if (time < 40) recommendations.add('⏰ Exam approaching - focus on weak areas');
    
    if (recommendations.isEmpty) {
      recommendations.add('✅ On track! Maintain current pace');
    }
    
    return recommendations;
  }
}

/// Readiness Score Model
class ReadinessScore {
  final int overall; // 0-100
  final int studyReadiness;
  final int knowledgeReadiness;
  final int fitnessReadiness;
  final int timeReadiness;
  final DateTime examDate;
  final List<String> recommendations;

  ReadinessScore({
    required this.overall,
    required this.studyReadiness,
    required this.knowledgeReadiness,
    required this.fitnessReadiness,
    required this.timeReadiness,
    required this.examDate,
    required this.recommendations,
  });

  String get readinessLevel {
    if (overall >= 80) return 'EXCELLENT';
    if (overall >= 60) return 'GOOD';
    if (overall >= 40) return 'FAIR';
    return 'NEEDS IMPROVEMENT';
  }

  String get emoji {
    if (overall >= 80) return '🎖️';
    if (overall >= 60) return '⭐';
    if (overall >= 40) return '📈';
    return '⚠️';
  }

  int get daysUntilExam => examDate.difference(DateTime.now()).inDays;
}

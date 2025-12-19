import 'package:prahar/data/datasources/firestore_service.dart';

/// Smart Study Recommendation Service
/// Analyzes quiz performance and study history to recommend what to study next
class StudyRecommendationService {
  final FirestoreService _firestoreService;

  StudyRecommendationService(this._firestoreService);

  /// Get personalized study recommendations for a user
  Future<List<StudyRecommendation>> getRecommendations(String userId) async {
    final recommendations = <StudyRecommendation>[];

    try {
      // Analyze quiz performance to find weak areas
      final weakTopics = await _analyzeQuizPerformance(userId);
      
      // Add recommendations for weak topics
      for (final topic in weakTopics.entries) {
        recommendations.add(StudyRecommendation(
          topic: topic.key,
          reason: 'Low quiz accuracy: ${topic.value.toStringAsFixed(0)}%',
          priority: _calculatePriority(topic.value),
          estimatedMinutes: 45,
          type: RecommendationType.weakArea,
        ));
      }

      // Add general recommendations if no weak areas identified
      if (recommendations.isEmpty) {
        recommendations.addAll(_getDefaultRecommendations());
      }

      // Sort by priority
      recommendations.sort((a, b) => b.priority.compareTo(a.priority));
      
      return recommendations.take(5).toList(); // Top 5 recommendations
    } catch (e) {
      print('Error getting study recommendations: $e');
      return _getDefaultRecommendations();
    }
  }

  /// Analyze quiz performance to identify weak topics
  Future<Map<String, double>> _analyzeQuizPerformance(String userId) async {
    final weakTopics = <String, double>{};

    try {
      // TODO: Fetch quiz sessions and analyze
      // For now, return empty to use defaults
      // Future enhancement: fetch quiz_sessions collection and calculate accuracy per subject
      
      return weakTopics;
    } catch (e) {
      print('Error analyzing quiz performance: $e');
      return {};
    }
  }

  /// Calculate priority score (0-100)
  int _calculatePriority(double accuracy) {
    // Lower accuracy = higher priority
    if (accuracy < 40) return 100;
    if (accuracy < 50) return 80;
    if (accuracy < 60) return 60;
    return 40;
  }

  /// Get default recommendations when no data available
  List<StudyRecommendation> _getDefaultRecommendations() {
    return [
      StudyRecommendation(
        topic: 'General Knowledge',
        reason: 'Foundation topic for CDS',
        priority: 70,
        estimatedMinutes: 45,
        type: RecommendationType.coreSubject,
      ),
      StudyRecommendation(
        topic: 'English',
        reason: 'High weightage in exam',
        priority: 65,
        estimatedMinutes: 30,
        type: RecommendationType.coreSubject,
      ),
      StudyRecommendation(
        topic: 'Mathematics',
        reason: 'Practice required for proficiency',
        priority: 60,
        estimatedMinutes: 60,
        type: RecommendationType.coreSubject,
      ),
    ];
  }

  /// Get next recommended study topic (simple version)
  Future<String?> getNextStudyTopic(String userId) async {
    final recommendations = await getRecommendations(userId);
    return recommendations.isNotEmpty ? recommendations.first.topic : null;
  }
}

/// Study Recommendation Model
class StudyRecommendation {
  final String topic;
  final String reason;
  final int priority; // 0-100
  final int estimatedMinutes;
  final RecommendationType type;

  StudyRecommendation({
    required this.topic,
    required this.reason,
    required this.priority,
    required this.estimatedMinutes,
    required this.type,
  });

  String get priorityLabel {
    if (priority >= 80) return 'HIGH';
    if (priority >= 60) return 'MEDIUM';
    return 'LOW';
  }

  String get icon {
    switch (type) {
      case RecommendationType.weakArea:
        return '⚠️';
      case RecommendationType.reviewNeeded:
        return '🔄';
      case RecommendationType.coreSubject:
        return '📚';
      case RecommendationType.examPrep:
        return '🎯';
    }
  }
}

enum RecommendationType {
  weakArea,      // Based on poor quiz performance
  reviewNeeded,  // Spaced repetition review
  coreSubject,   // Core CDS subjects
  examPrep,      // Exam-specific preparation
}

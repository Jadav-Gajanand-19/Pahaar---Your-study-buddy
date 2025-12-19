import 'package:cloud_firestore/cloud_firestore.dart';

/// Quiz Session Model - Stores completed quiz results
class QuizSession {
  final String? id;
  final String subject; // english, gk, math
  final String difficulty; // easy, medium, hard
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unattempted;
  final double scorePercentage;
  final int durationSeconds;
  final DateTime completedAt;
  
  // NEW: Enhanced tracking for study recommendations
  final List<String>? weakTopics; // Topics with low performance
  final Map<String, double>? topicAccuracy; // Topic -> accuracy mapping
  final bool contributedToChallenge; // Whether this counted toward a challenge

  QuizSession({
    this.id,
    required this.subject,
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unattempted,
    required this.scorePercentage,
    required this.durationSeconds,
    required this.completedAt,
    this.weakTopics,
    this.topicAccuracy,
    this.contributedToChallenge = false,
  });

  factory QuizSession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return QuizSession(
      id: doc.id,
      subject: data['subject'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      incorrectAnswers: data['incorrectAnswers'] ?? 0,
      unattempted: data['unattempted'] ?? 0,
      scorePercentage: (data['scorePercentage'] ?? 0.0).toDouble(),
      durationSeconds: data['durationSeconds'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      weakTopics: data['weakTopics'] != null ? List<String>.from(data['weakTopics']) : null,
      topicAccuracy: data['topicAccuracy'] != null 
          ? Map<String, double>.from((data['topicAccuracy'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())))
          : null,
      contributedToChallenge: data['contributedToChallenge'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unattempted': unattempted,
      'scorePercentage': scorePercentage,
      'durationSeconds': durationSeconds,
      'completedAt': Timestamp.fromDate(completedAt),
      'weakTopics': weakTopics,
      'topicAccuracy': topicAccuracy,
      'contributedToChallenge': contributedToChallenge,
    };
  }
  
  double get accuracy => scorePercentage / 100.0;
}

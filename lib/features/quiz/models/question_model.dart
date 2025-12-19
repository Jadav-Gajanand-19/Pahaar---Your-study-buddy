import 'package:cloud_firestore/cloud_firestore.dart';

/// Question Model - MCQ for CDS preparation
class Question {
  final String? id;
  final String questionText;
  final List<String> options; // 4 options (A, B, C, D)
  final int correctAnswerIndex; // 0-3
  final String? explanation;
  final CDSSubject subject;
  final String? topic;
  final DifficultyLevel difficulty;
  final int? year; // Which year's exam
  final List<String>? tags;

  Question({
    this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    required this.subject,
    this.topic,
    required this.difficulty,
    this.year,
    this.tags,
  });

  // Convert from Firestore
  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'],
      subject: CDSSubject.values.firstWhere(
        (e) => e.toString() == data['subject'],
        orElse: () => CDSSubject.general,
      ),
      topic: data['topic'],
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == data['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      year: data['year'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'subject': subject.toString(),
      'topic': topic,
      'difficulty': difficulty.toString(),
      'year': year,
      'tags': tags,
    };
  }

  // Get correct answer
  String get correctAnswer => options[correctAnswerIndex];

  // Check if answer is correct
  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}

/// CDS Subjects
enum CDSSubject {
  english,
  math,
  general,
}

/// Difficulty Levels
enum DifficultyLevel {
  easy,
  medium,
  hard,
}

/// Quiz Session Model - Track a quiz attempt
class QuizSession {
  final String? id;
  final String userId;
  final List<String> questionIds;
  final Map<String, int> userAnswers; // questionId -> selectedIndex
  final DateTime startTime;
  final DateTime? endTime;
  final int? score;
  final CDSSubject? subject;
  final DifficultyLevel? difficulty;

  QuizSession({
    this.id,
    required this.userId,
    required this.questionIds,
    required this.userAnswers,
    required this.startTime,
    this.endTime,
    this.score,
    this.subject,
    this.difficulty,
  });

  // Convert from Firestore
  factory QuizSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      questionIds: List<String>.from(data['questionIds'] ?? []),
      userAnswers: Map<String, int>.from(data['userAnswers'] ?? {}),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      score: data['score'],
      subject: data['subject'] != null
          ? CDSSubject.values.firstWhere(
              (e) => e.toString() == data['subject'],
              orElse: () => CDSSubject.general,
            )
          : null,
      difficulty: data['difficulty'] != null
          ? DifficultyLevel.values.firstWhere(
              (e) => e.toString() == data['difficulty'],
              orElse: () => DifficultyLevel.medium,
            )
          : null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questionIds': questionIds,
      'userAnswers': userAnswers,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'score': score,
      'subject': subject?.toString(),
      'difficulty': difficulty?.toString(),
    };
  }

  // Calculate score
  int calculateScore(List<Question> questions) {
    int correct = 0;
    for (var question in questions) {
      if (userAnswers.containsKey(question.id)) {
        if (question.isCorrect(userAnswers[question.id]!)) {
          correct++;
        }
      }
    }
    return correct;
  }

  // Get percentage
  double getPercentage() {
    if (score == null || questionIds.isEmpty) return 0.0;
    return (score! / questionIds.length) * 100;
  }

  // Get time taken
  Duration? getTimeTaken() {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  // Copy with
  QuizSession copyWith({
    String? id,
    String? userId,
    List<String>? questionIds,
    Map<String, int>? userAnswers,
    DateTime? startTime,
    DateTime? endTime,
    int? score,
    CDSSubject? subject,
    DifficultyLevel? difficulty,
  }) {
    return QuizSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionIds: questionIds ?? this.questionIds,
      userAnswers: userAnswers ?? this.userAnswers,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      score: score ?? this.score,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

// Extension methods
extension CDSSubjectExtension on CDSSubject {
  String get displayName {
    switch (this) {
      case CDSSubject.english:
        return 'English';
      case CDSSubject.math:
        return 'Mathematics';
      case CDSSubject.general:
        return 'General Knowledge';
    }
  }

  String get icon {
    switch (this) {
      case CDSSubject.english:
        return '📝';
      case CDSSubject.math:
        return '🔢';
      case CDSSubject.general:
        return '🌍';
    }
  }
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String get militaryName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'BASIC TRAINING';
      case DifficultyLevel.medium:
        return 'TACTICAL ASSAULT';
      case DifficultyLevel.hard:
        return 'ELITE OPERATIONS';
    }
  }
}

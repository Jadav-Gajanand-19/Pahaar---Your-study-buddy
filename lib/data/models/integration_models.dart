import 'package:cloud_firestore/cloud_firestore.dart';

/// XP Transaction Model - Tracks all XP awards to prevent duplicates
class XPTransaction {
  final String? id;
  final String userId;
  final String sourceId; // ID of the activity (studySession.id, workout.id, etc.)
  final String sourceType; // 'study', 'quiz', 'workout', 'habit', 'challenge'
  final int amount;
  final DateTime awardedAt;
  final String? description;

  XPTransaction({
    this.id,
    required this.userId,
    required this.sourceId,
    required this.sourceType,
    required this.amount,
    required this.awardedAt,
    this.description,
  });

  factory XPTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return XPTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      sourceId: data['sourceId'] ?? '',
      sourceType: data['sourceType'] ?? '',
      amount: data['amount'] ?? 0,
      awardedAt: (data['awardedAt'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sourceId': sourceId,
      'sourceType': sourceType,
      'amount': amount,
      'awardedAt': Timestamp.fromDate(awardedAt),
      'description': description,
    };
  }
}

/// Weekly Aggregate Model - Pre-calculated weekly statistics
class WeeklyAggregate {
  final String? id; // Format: "2024-W52"
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalStudyMinutes;
  final int totalWorkouts;
  final int quizzesTaken;
  final double averageQuizScore;
  final double habitsCompletionRate;
  final int xpEarned;
  final int challengesCompleted;
  final DateTime generatedAt;

  WeeklyAggregate({
    this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalStudyMinutes,
    required this.totalWorkouts,
    required this.quizzesTaken,
    required this.averageQuizScore,
    required this.habitsCompletionRate,
    required this.xpEarned,
    required this.challengesCompleted,
    required this.generatedAt,
  });

  factory WeeklyAggregate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeeklyAggregate(
      id: doc.id,
      userId: data['userId'] ?? '',
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      totalStudyMinutes: data['totalStudyMinutes'] ?? 0,
      totalWorkouts: data['totalWorkouts'] ?? 0,
      quizzesTaken: data['quizzesTaken'] ?? 0,
      averageQuizScore: (data['averageQuizScore'] ?? 0.0).toDouble(),
      habitsCompletionRate: (data['habitsCompletionRate'] ?? 0.0).toDouble(),
      xpEarned: data['xpEarned'] ?? 0,
      challengesCompleted: data['challengesCompleted'] ?? 0,
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'totalStudyMinutes': totalStudyMinutes,
      'totalWorkouts': totalWorkouts,
      'quizzesTaken': quizzesTaken,
      'averageQuizScore': averageQuizScore,
      'habitsCompletionRate': habitsCompletionRate,
      'xpEarned': xpEarned,
      'challengesCompleted': challengesCompleted,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }
}

/// Topic Performance Stats - Tracks quiz performance by topic
class TopicStats {
  final String? id; // topicName
  final String userId;
  final String topicName;
  final String subject; // Parent subject
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final DateTime lastPracticed;
  final int recommendationPriority; // 0-100, higher = more important to study

  TopicStats({
    this.id,
    required this.userId,
    required this.topicName,
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.lastPracticed,
    required this.recommendationPriority,
  });

  factory TopicStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopicStats(
      id: doc.id,
      userId: data['userId'] ?? '',
      topicName: data['topicName'] ?? '',
      subject: data['subject'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      accuracy: (data['accuracy'] ?? 0.0).toDouble(),
      lastPracticed: (data['lastPracticed'] as Timestamp).toDate(),
      recommendationPriority: data['recommendationPriority'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'topicName': topicName,
      'subject': subject,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'lastPracticed': Timestamp.fromDate(lastPracticed),
      'recommendationPriority': recommendationPriority,
    };
  }
}

/// Fitness Progress Tracker - SSB readiness aggregate
class FitnessProgress {
  final String userId;
  final double runningPB;
  final DateTime? runningPBDate;
  final int pushupsPB;
  final DateTime? pushupsPBDate;
  final int situpsPB;
  final DateTime? situpsPBDate;
  final int pullupsPB;
  final DateTime? pullupsPBDate;
  final int ssbReadinessScore; // 0-100
  final DateTime lastUpdated;

  FitnessProgress({
    required this.userId,
    required this.runningPB,
    this.runningPBDate,
    required this.pushupsPB,
    this.pushupsPBDate,
    required this.situpsPB,
    this.situpsPBDate,
    required this.pullupsPB,
    this.pullupsPBDate,
    required this.ssbReadinessScore,
    required this.lastUpdated,
  });

  factory FitnessProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FitnessProgress(
      userId: data['userId'] ?? '',
      runningPB: (data['runningPB'] ?? 0.0).toDouble(),
      runningPBDate: data['runningPBDate'] != null ? (data['runningPBDate'] as Timestamp).toDate() : null,
      pushupsPB: data['pushupsPB'] ?? 0,
      pushupsPBDate: data['pushupsPBDate'] != null ? (data['pushupsPBDate'] as Timestamp).toDate() : null,
      situpsPB: data['situpsPB'] ?? 0,
      situpsPBDate: data['situpsPBDate'] != null ? (data['situpsPBDate'] as Timestamp).toDate() : null,
      pullupsPB: data['pullupsPB'] ?? 0,
      pullupsPBDate: data['pullupsPBDate'] != null ? (data['pullupsPBDate'] as Timestamp).toDate() : null,
      ssbReadinessScore: data['ssbReadinessScore'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'runningPB': runningPB,
      'runningPBDate': runningPBDate != null ? Timestamp.fromDate(runningPBDate!) : null,
      'pushupsPB': pushupsPB,
      'pushupsPBDate': pushupsPBDate != null ? Timestamp.fromDate(pushupsPBDate!) : null,
      'situpsPB': situpsPB,
      'situpsPBDate': situpsPBDate != null ? Timestamp.fromDate(situpsPBDate!) : null,
      'pullupsPB': pullupsPB,
      'pullupsPBDate': pullupsPBDate != null ? Timestamp.fromDate(pullupsPBDate!) : null,
      'ssbReadinessScore': ssbReadinessScore,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/data/models/integration_models.dart';


/// Database Integration Service -Handles transactions and data relationships
class DatabaseIntegrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== XP TRANSACTION MANAGEMENT ====================
  
  /// Check if XP has already been awarded for an activity
  Future<bool> xpTransactionExists(String userId, String activityId) async {
    try {
      final query = await _db
          .collection('users')
          .doc(userId)
          .collection('xp_transactions')
          .where('sourceId', isEqualTo: activityId)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking XP transaction: $e');
      return false;
    }
  }

  /// Record an XP transaction
  Future<void> recordXPTransaction(XPTransaction transaction) async {
    try {
      await _db
          .collection('users')
          .doc(transaction.userId)
          .collection('xp_transactions')
          .add(transaction.toFirestore());
    } catch (e) {
      print('Error recording XP transaction: $e');
      rethrow;
    }
  }

  /// Get all XP transactions for a user
  Stream<List<XPTransaction>> getXPTransactions(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('xp_transactions')
        .orderBy('awardedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XPTransaction.fromFirestore(doc))
            .toList());
  }

  // ==================== ATOMIC REWARD AWARDING ====================
  
  /// Award XP with transaction support (all-or-nothing)
  /// Returns XP amount awarded (0 if already awarded or failed)
  Future<int> awardXPAtomic({
    required String userId,
    required String activityId,
    required String activityType,
    required int xpAmount,
    String? description,
  }) async {
    try {
      // Check if already awarded
      if (await xpTransactionExists(userId, activityId)) {
        print('XP already awarded for activity: $activityId');
        return 0;
      }

      // Atomic transaction
      return await _db.runTransaction<int>((transaction) async {
        // Get user stats
        final statsRef = _db.collection('users').doc(userId).collection('user_stats').doc(userId);
        final statsSnapshot = await transaction.get(statsRef);

        int currentXP = 0;
        if (statsSnapshot.exists) {
          currentXP = statsSnapshot.data()?['xp'] ?? 0;
        }

        final newXP = currentXP + xpAmount;

        // Update stats
        transaction.set(
          statsRef,
          {
            'userId': userId,
            'xp': newXP,
            'lastXPUpdate': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Record transaction
        final transactionRef = _db
            .collection('users')
            .doc(userId)
            .collection('xp_transactions')
            .doc();

        transaction.set(transactionRef, {
          'userId': userId,
          'sourceId': activityId,
          'sourceType': activityType,
          'amount': xpAmount,
          'awardedAt': FieldValue.serverTimestamp(),
          'description': description,
        });

        return xpAmount;
      });
    } catch (e) {
      print('Error in atomic XP award: $e');
      return 0;
    }
  }



  // ==================== WEEKLY AGGREGATES ====================
  
  /// Save or update weekly aggregate
  Future<void> saveWeeklyAggregate(WeeklyAggregate aggregate) async {
    try {
      final weekId = _getWeekId(aggregate.weekStart);
      await _db
          .collection('users')
          .doc(aggregate.userId)
          .collection('weekly_aggregates')
          .doc(weekId)
          .set(aggregate.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving weekly aggregate: $e');
      rethrow;
    }
  }

  /// Get weekly aggregate
  Future<WeeklyAggregate?> getWeeklyAggregate(String userId, DateTime weekStart) async {
    try {
      final weekId = _getWeekId(weekStart);
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('weekly_aggregates')
          .doc(weekId)
          .get();

      if (doc.exists) {
        return WeeklyAggregate.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting weekly aggregate: $e');
      return null;
    }
  }

  String _getWeekId(DateTime date) {
    final year = date.year;
    final weekNumber = ((date.difference(DateTime(year, 1, 1)).inDays) / 7).ceil() + 1;
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  // ==================== TOPIC STATS ====================
  
  /// Update topic statistics
  Future<void> updateTopicStats({
    required String userId,
    required String topicName,
    required String subject,
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    try {
      final topicRef = _db
          .collection('users')
          .doc(userId)
          .collection('topic_stats')
          .doc(topicName);

      await _db.runTransaction((transaction) async {
        final topicSnapshot = await transaction.get(topicRef);

        if (topicSnapshot.exists) {
          // Update existing
          final existingData = topicSnapshot.data() as Map<String, dynamic>;
          final oldTotal = existingData['totalQuestions'] ?? 0;
          final oldCorrect = existingData['correctAnswers'] ?? 0;

          final newTotal = oldTotal + questionsAnswered;
          final newCorrect = oldCorrect + correctAnswers;
          final newAccuracy = newTotal > 0 ? (newCorrect / newTotal) * 100 : 0.0;

          // Calculate priority (lower accuracy = higher priority)
          final priority = (100 - newAccuracy).clamp(0, 100).toInt();

          transaction.update(topicRef, {
            'totalQuestions': newTotal,
            'correctAnswers': newCorrect,
            'accuracy': newAccuracy,
            'lastPracticed': FieldValue.serverTimestamp(),
            'recommendationPriority': priority,
          });
        } else {
          // Create new
          final accuracy = questionsAnswered > 0 
              ? (correctAnswers / questionsAnswered) * 100 
              : 0.0;
          final priority = (100 - accuracy).clamp(0, 100).toInt();

          transaction.set(topicRef, {
            'userId': userId,
            'topicName': topicName,
            'subject': subject,
            'totalQuestions': questionsAnswered,
            'correctAnswers': correctAnswers,
            'accuracy': accuracy,
            'lastPracticed': FieldValue.serverTimestamp(),
            'recommendationPriority': priority,
          });
        }
      });
    } catch (e) {
      print('Error updating topic stats: $e');
      rethrow;
    }
  }

  /// Get topic stats for recommendations
  Stream<List<TopicStats>> getTopicStats(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('topic_stats')
        .orderBy('recommendationPriority', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TopicStats.fromFirestore(doc))
            .toList());
  }

  // ==================== FITNESS PROGRESS ====================
  
  /// Update fitness progress
  Future<void> updateFitnessProgress(FitnessProgress progress) async {
    try {
      await _db
          .collection('users')
          .doc(progress.userId)
          .collection('fitness_progress')
          .doc(progress.userId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating fitness progress: $e');
      rethrow;
    }
  }

  /// Get fitness progress
  Future<FitnessProgress?> getFitnessProgress(String userId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('fitness_progress')
          .doc(userId)
          .get();

      if (doc.exists) {
        return FitnessProgress.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting fitness progress: $e');
      return null;
    }
  }
}

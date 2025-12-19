import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/features/gamification/models/user_stats_model.dart';


/// XP Service - Handles XP awarding and level calculations
class XPService {
  final FirestoreService _firestoreService;

  XPService(this._firestoreService);

  // XP per level (linear progression)
  static const int xpPerLevel = 500;

  /// Award XP to user and check for level up
  Future<Map<String, dynamic>> awardXP(
    String userId,
    int amount,
    String reason,
  ) async {
    try {
      // Get current stats
      final stats = await _firestoreService.getUserStats(userId);
      
      if (stats == null) {
        // Create initial stats if not exists
        final newStats = UserStats(
          userId: userId,
          xp: amount,
          level: calculateLevel(amount),
        );
        await _firestoreService.createUserStats(newStats);
        
        return {
          'xpAwarded': amount,
          'totalXP': amount,
          'leveledUp': false,
          'newLevel': 1,
        };
      }

      // Add XP
      final newXP = stats.xp + amount;
      final oldLevel = stats.level;
      final newLevel = calculateLevel(newXP);
      final leveledUp = newLevel > oldLevel;

      // Update stats
      await _firestoreService.updateUserStats(userId, {
        'xp': newXP,
        'level': newLevel,
      });

      return {
        'xpAwarded': amount,
        'totalXP': newXP,
        'leveledUp': leveledUp,
        'oldLevel': oldLevel,
        'newLevel': newLevel,
      };
    } catch (e) {
      print('Error awarding XP: $e');
      rethrow;
    }
  }

  /// Calculate level from XP
  static int calculateLevel(int xp) {
    return (xp / xpPerLevel).floor() + 1;
  }

  /// Calculate XP needed for next level
  static int xpForNextLevel(int currentXP) {
    final currentLevel = calculateLevel(currentXP);
    final nextLevelXP = currentLevel * xpPerLevel;
    return nextLevelXP - currentXP;
  }

  /// Calculate progress to next level (0.0 to 1.0)
  static double levelProgress(int currentXP) {
    final currentLevel = calculateLevel(currentXP);
    final levelStartXP = (currentLevel - 1) * xpPerLevel;
    final levelEndXP = currentLevel * xpPerLevel;
    final progressXP = currentXP - levelStartXP;
    final totalXPNeeded = levelEndXP - levelStartXP;
    return progressXP / totalXPNeeded;
  }

  /// Get military rank based on level
  static String getMilitaryRank(int level) {
    if (level >= 50) return 'General';
    if (level >= 40) return 'Colonel';
    if (level >= 30) return 'Major';
    if (level >= 20) return 'Captain';
    if (level >= 10) return 'Lieutenant';
    if (level >= 5) return 'Sergeant';
    return 'Cadet';
  }

  // XP Award Amounts
  static const int xpPerStudyHalfHour = 10;
  static const int xpPerWorkout = 15;
  static const int xpPerHabit = 5;
  static const int xpPerQuizMin = 5;
  static const int xpPerQuizMax = 20;
  static const int xpPerMockTestMin = 50;
  static const int xpPerMockTestMax = 100;


  /// Calculate XP for study session based on duration
  static int calculateStudyXP(int durationMinutes) {
    return (durationMinutes / 30).floor() * xpPerStudyHalfHour;
  }

  /// Calculate XP for quiz based on score percentage
  static int calculateQuizXP(double scorePercentage) {
    if (scorePercentage >= 90) return xpPerQuizMax;
    if (scorePercentage >= 75) return 15;
    if (scorePercentage >= 60) return 10;
    return xpPerQuizMin;
  }

  /// Calculate XP for mock test based on performance
  static int calculateMockTestXP(double scorePercentage, int totalQuestions) {
    final baseXP = scorePercentage >= 80 ? xpPerMockTestMax : xpPerMockTestMin;
    final bonusXP = totalQuestions > 100 ? 20 : 0; // Bonus for longer tests
    return baseXP + bonusXP;
  }


}

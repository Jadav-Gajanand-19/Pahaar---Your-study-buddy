import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/core/services/xp_service.dart';
import 'package:prahar/core/services/achievement_service.dart';

import 'package:prahar/core/services/database_integration_service.dart';

/// Automation Service - Orchestrates all automation services
class AutomationService {
  final FirestoreService _firestoreService;
  final XPService _xpService;
  final AchievementService _achievementService;
  final DatabaseIntegrationService _dbIntegration;

  AutomationService(
    this._firestoreService,
    this._xpService,
    this._achievementService,
    this._dbIntegration,
  );

  /// Handle study session completion with atomic transactions
  Future<Map<String, dynamic>> onStudySessionComplete(
    String userId,
    String sessionId, // NEW: Required for duplicate prevention
    int durationMinutes,
  ) async {
    final results = <String, dynamic>{};

    try {
      print('🎯 Automation: Study session complete - $durationMinutes minutes');
      
      // Award XP (atomic, prevents duplicates)
      final xpAmount = XPService.calculateStudyXP(durationMinutes);
      final xpAwarded = await _dbIntegration.awardXPAtomic(
        userId: userId,
        activityId: sessionId,
        activityType: 'study',
        xpAmount: xpAmount,
        description: 'Study session: $durationMinutes min',
      );
      
      results['xp'] = {
        'xpAwarded': xpAwarded,
        'wasDuplicate': xpAwarded == 0,
      };
      print('✅ XP Awarded: $xpAwarded${xpAwarded == 0 ? " (duplicate prevented)" : ""}');

      // Check achievements
      final unlockedAchievements = await _achievementService.checkAndUnlockAchievements(
        userId,
        'study',
        {'duration': durationMinutes},
      );
      results['unlockedAchievements'] = unlockedAchievements;
      print('✅ Achievements unlocked: ${unlockedAchievements.length}');

      return results;
    } catch (e) {
      print('❌ Error in study session automation: $e');
      print('Stack trace: ${StackTrace.current}');
      return results;
    }
  }

  /// Handle quiz completion
  Future<Map<String, dynamic>> onQuizComplete(
    String userId,
    int correctAnswers,
    int totalQuestions,
  ) async {
    final results = <String, dynamic>{};

    try {
      final scorePercentage = (correctAnswers / totalQuestions) * 100;

      // Award XP
      final xpResult = await _xpService.awardXP(
        userId,
        XPService.calculateQuizXP(scorePercentage),
        'quiz_completion',
      );
      results['xp'] = xpResult;

      // Check achievements
      final unlockedAchievements = await _achievementService.checkAndUnlockAchievements(
        userId,
        'quiz',
        {'score': scorePercentage},
      );
      results['unlockedAchievements'] = unlockedAchievements;

      return results;
    } catch (e) {
      print('Error in quiz automation: $e');
      return results;
    }
  }

  /// Handle workout completion
  Future<Map<String, dynamic>> onWorkoutComplete(String userId) async {
    final results = <String, dynamic>{};

    try {
      // Award XP
      final xpResult = await _xpService.awardXP(
        userId,
        XPService.xpPerWorkout,
        'workout',
      );
      results['xp'] = xpResult;

      // Check achievements
      final unlockedAchievements = await _achievementService.checkAndUnlockAchievements(
        userId,
        'fitness',
        {},
      );
      results['unlockedAchievements'] = unlockedAchievements;

      return results;
    } catch (e) {
      print('Error in workout automation: $e');
      return results;
    }
  }

  /// Handle habit completion
  Future<Map<String, dynamic>> onHabitComplete(String userId) async {
    final results = <String, dynamic>{};

    try {
      // Award XP
      final xpResult = await _xpService.awardXP(
        userId,
        XPService.xpPerHabit,
        'habit_completion',
      );
      results['xp'] = xpResult;

      return results;
    } catch (e) {
      print('Error in habit automation: $e');
      return results;
    }
  }

  /// Handle mock test completion
  Future<Map<String, dynamic>> onMockTestComplete(
    String userId,
    double scorePercentage,
    int totalQuestions,
  ) async {
    final results = <String, dynamic>{};

    try {
      // Award XP
      final xpResult = await _xpService.awardXP(
        userId,
        XPService.calculateMockTestXP(scorePercentage, totalQuestions),
        'mock_test',
      );
      results['xp'] = xpResult;

      return results;
    } catch (e) {
      print('Error in mock test automation: $e');
      return results;
    }
  }

  /// Show automation results to user
  static String formatResults(Map<String, dynamic> results) {
    final messages = <String>[];

    // XP message
    if (results.containsKey('xp')) {
      final xp = results['xp'] as Map<String, dynamic>;
      messages.add('+${xp['xpAwarded']} XP');
      
      if (xp['leveledUp'] == true) {
        messages.add('🎉 Level Up! Now Level ${xp['newLevel']}');
      }
    }

    // Achievements
    if (results.containsKey('unlockedAchievements')) {
      final achievements = results['unlockedAchievements'] as List;
      for (final achievement in achievements) {
        // Achievement objects have 'name' property, not 'title'
        final name = achievement is Map ? (achievement['name'] ?? 'Unknown') : achievement.name;
        messages.add('🏆 Achievement Unlocked: $name');
      }
    }

    return messages.isEmpty ? '0 XP Unlocked' : messages.join('\n');
  }
}

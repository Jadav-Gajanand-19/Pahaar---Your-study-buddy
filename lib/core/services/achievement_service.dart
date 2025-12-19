import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/core/services/xp_service.dart';

/// Achievement Definitions
class Achievement {
  final String id;
  final String title;
  final String description;
  final String category; // study, fitness, quiz, streak, challenge
  final int xpReward;
  final String icon;
  final Map<String, dynamic> criteria; // Unlock criteria

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpReward,
    required this.icon,
    required this.criteria,
  });
}

/// Achievement Service - Automatically detect and unlock achievements
class AchievementService {
  final FirestoreService _firestoreService;
  final XPService _xpService;

  AchievementService(this._firestoreService, this._xpService);

  // Achievement Definitions
  static final List<Achievement> allAchievements = [
    // Study Achievements
    Achievement(
      id: 'first_study',
      title: 'First Steps',
      description: 'Complete your first study session',
      category: 'study',
      xpReward: 10,
      icon: '📚',
      criteria: {'type': 'study_count', 'value': 1},
    ),
    Achievement(
      id: 'study_10h',
      title: 'Dedicated Scholar',
      description: 'Study for 10 hours total',
      category: 'study',
      xpReward: 50,
      icon: '📖',
      criteria: {'type': 'study_hours', 'value': 10},
    ),
    Achievement(
      id: 'study_50h',
      title: 'Academic Warrior',
      description: 'Study for 50 hours total',
      category: 'study',
      xpReward: 100,
      icon: '🎓',
      criteria: {'type': 'study_hours', 'value': 50},
    ),
    Achievement(
      id: 'study_100h',
      title: 'Knowledge Seeker',
      description: 'Study for 100 hours total',
      category: 'study',
      xpReward: 200,
      icon: '🏆',
      criteria: {'type': 'study_hours', 'value': 100},
    ),
    Achievement(
      id: 'marathon_session',
      title: 'Marathon Runner',
      description: 'Complete a 4+ hour study session',
      category: 'study',
      xpReward: 75,
      icon: '⏱️',
      criteria: {'type': 'single_session', 'value': 240},
    ),

    // Fitness Achievements
    Achievement(
      id: 'first_workout',
      title: 'First PT',
      description: 'Complete your first workout',
      category: 'fitness',
      xpReward: 10,
      icon: '💪',
      criteria: {'type': 'workout_count', 'value': 1},
    ),
    Achievement(
      id: 'workout_10',
      title: 'Fitness Enthusiast',
      description: 'Complete 10 workouts',
      category: 'fitness',
      xpReward: 50,
      icon: '🏋️',
      criteria: {'type': 'workout_count', 'value': 10},
    ),
    Achievement(
      id: 'ssb_ready',
      title: 'SSB Ready',
      description: 'Meet all SSB fitness standards',
      category: 'fitness',
      xpReward: 150,
      icon: '🎖️',
      criteria: {'type': 'ssb_standards', 'value': true},
    ),
    Achievement(
      id: 'workout_streak_7',
      title: 'Iron Will',
      description: '7-day workout streak',
      category: 'fitness',
      xpReward: 100,
      icon: '🔥',
      criteria: {'type': 'workout_streak', 'value': 7},
    ),

    // Quiz Achievements
    Achievement(
      id: 'first_quiz',
      title: 'Quick Learner',
      description: 'Complete your first quiz',
      category: 'quiz',
      xpReward: 10,
      icon: '❓',
      criteria: {'type': 'quiz_count', 'value': 1},
    ),
    Achievement(
      id: 'quiz_master',
      title: 'Quiz Master',
      description: 'Score 90%+ on any quiz',
      category: 'quiz',
      xpReward: 50,
      icon: '🎯',
      criteria: {'type': 'quiz_score', 'value': 90},
    ),
    Achievement(
      id: 'perfect_score',
      title: 'Perfect Score',
      description: 'Score 100% on any quiz',
      category: 'quiz',
      xpReward: 100,
      icon: '⭐',
      criteria: {'type': 'quiz_score', 'value': 100},
    ),
    Achievement(
      id: 'quiz_warrior',
      title: 'Quiz Warrior',
      description: 'Complete 50 quizzes',
      category: 'quiz',
      xpReward: 150,
      icon: '🏅',
      criteria: {'type': 'quiz_count', 'value': 50},
    ),

    // Streak Achievements
    Achievement(
      id: 'streak_7',
      title: 'Consistent',
      description: '7-day study streak',
      category: 'streak',
      xpReward: 50,
      icon: '📅',
      criteria: {'type': 'study_streak', 'value': 7},
    ),
    Achievement(
      id: 'streak_30',
      title: 'Dedicated',
      description: '30-day study streak',
      category: 'streak',
      xpReward: 150,
      icon: '🔥',
      criteria: {'type': 'study_streak', 'value': 30},
    ),
    Achievement(
      id: 'streak_100',
      title: 'Unstoppable',
      description: '100-day study streak',
      category: 'streak',
      xpReward: 500,
      icon: '👑',
      criteria: {'type': 'study_streak', 'value': 100},
    ),


  ];

  /// Check and unlock achievements based on user action
  Future<List<Achievement>> checkAndUnlockAchievements(
    String userId,
    String actionType,
    Map<String, dynamic> data,
  ) async {
    final unlockedAchievements = <Achievement>[];

    try {
      // Get already unlocked achievements
      final unlockedIds = await _firestoreService
          .getUnlockedAchievementIds(userId)
          .first;

      // Check each achievement
      for (final achievement in allAchievements) {
        // Skip if already unlocked
        if (unlockedIds.contains(achievement.id)) continue;

        // Check if criteria met
        final shouldUnlock = await _checkCriteria(
          userId,
          achievement,
          actionType,
          data,
        );

        if (shouldUnlock) {
          // Unlock achievement
          await _unlockAchievement(userId, achievement);
          unlockedAchievements.add(achievement);
        }
      }

      return unlockedAchievements;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  /// Check if achievement criteria is met
  Future<bool> _checkCriteria(
    String userId,
    Achievement achievement,
    String actionType,
    Map<String, dynamic> data,
  ) async {
    final criteriaType = achievement.criteria['type'] as String;
    final criteriaValue = achievement.criteria['value'];

    switch (criteriaType) {
      case 'study_count':
        // Check total study sessions
        if (actionType == 'study') {
          final sessions = await _firestoreService
              .getSessionsForDateRange(
                userId,
                DateTime(2000),
                DateTime.now(),
              )
              .first;
          return sessions.length >= criteriaValue;
        }
        break;

      case 'study_hours':
        // Check total study hours
        if (actionType == 'study') {
          final sessions = await _firestoreService
              .getSessionsForDateRange(
                userId,
                DateTime(2000),
                DateTime.now(),
              )
              .first;
          final totalMinutes = sessions.fold<int>(
            0,
            (sum, session) => sum + (session.durationInSeconds / 60).floor(),
          );
          return (totalMinutes / 60) >= criteriaValue;
        }
        break;

      case 'single_session':
        // Check single session duration
        if (actionType == 'study' && data.containsKey('duration')) {
          return data['duration'] >= criteriaValue;
        }
        break;

      case 'workout_count':
        // Check total workouts
        if (actionType == 'fitness') {
          final workouts = await _firestoreService.getWorkouts(userId).first;
          return workouts.length >= criteriaValue;
        }
        break;

      case 'quiz_count':
        // Check total quizzes
        if (actionType == 'quiz') {
          final quizzes = await _firestoreService.getUserQuizSessions(userId).first;
          return quizzes.length >= criteriaValue;
        }
        break;

      case 'quiz_score':
        // Check quiz score
        if (actionType == 'quiz' && data.containsKey('score')) {
          return data['score'] >= criteriaValue;
        }
        break;



      default:
        return false;
    }

    return false;
  }

  /// Unlock achievement and award XP
  Future<void> _unlockAchievement(String userId, Achievement achievement) async {
    try {
      // Unlock in Firestore
      await _firestoreService.unlockAchievement(
        userId,
        achievement.id,
        DateTime.now(),
      );

      // Award XP
      await _xpService.awardXP(
        userId,
        achievement.xpReward,
        'achievement_${achievement.id}',
      );

      print('Achievement unlocked: ${achievement.title} (+${achievement.xpReward} XP)');
    } catch (e) {
      print('Error unlocking achievement: $e');
      rethrow;
    }
  }

  /// Get achievement by ID
  static Achievement? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getAchievementsByCategory(String category) {
    return allAchievements.where((a) => a.category == category).toList();
  }
}

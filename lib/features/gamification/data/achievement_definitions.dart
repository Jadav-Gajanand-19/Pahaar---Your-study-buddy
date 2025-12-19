import 'package:prahar/features/gamification/models/achievement_model.dart';

/// Pre-defined achievements for CDS preparation
class AchievementDefinitions {
  // === STUDY ACHIEVEMENTS ===
  static final studyNewbie = Achievement(
    id: 'study_newbie',
    name: 'Rookie Scholar',
    description: 'Complete your first study session',
    icon: '📚',
    category: AchievementCategory.study,
    rarity: AchievementRarity.common,
    unlockCondition: {'type': 'study_sessions', 'value': 1},
    xpReward: 10,
    criteria: 'Complete 1 Study Session',
    tag: 'NOVICE',
  );

  static final study10Hours = Achievement(
    id: 'study_10h',
    name: 'Dedicated Learner',
    description: 'Study for 10 total hours',
    icon: '⏰',
    category: AchievementCategory.study,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'study_hours', 'value': 10},
    xpReward: 50,
    criteria: 'Accumulate 10 Hours of Study',
    tag: 'DEDICATION',
  );

  static final study50Hours = Achievement(
    id: 'study_50h',
    name: 'Study Warrior',
    description: 'Study for 50 total hours',
    icon: '🎯',
    category: AchievementCategory.study,
    rarity: AchievementRarity.rare,
    unlockCondition: {'type': 'study_hours', 'value': 50},
    xpReward: 150,
    criteria: 'Accumulate 50 Hours of Study',
    tag: 'WARRIOR',
  );

  static final study100Hours = Achievement(
    id: 'study_100h',
    name: 'Scholar Supreme',
    description: 'Study for 100 total hours',
    icon: '🏆',
    category: AchievementCategory.study,
    rarity: AchievementRarity.epic,
    unlockCondition: {'type': 'study_hours', 'value': 100},
    xpReward: 300,
    criteria: 'Accumulate 100 Hours of Study',
    tag: 'SUPREME',
  );

  // === FITNESS ACHIEVEMENTS ===
  static final firstWorkout = Achievement(
    id: 'first_workout',
    name: 'First Mission',
    description: 'Complete your first workout',
    icon: '💪',
    category: AchievementCategory.fitness,
    rarity: AchievementRarity.common,
    unlockCondition: {'type': 'workouts', 'value': 1},
    xpReward: 10,
    criteria: 'Log 1 Workout',
    tag: 'RECRUIT',
  );

  static final fitness10Workouts = Achievement(
    id: 'fitness_10',
    name: 'Fitness Enthusiast',
    description: 'Complete 10 workouts',
    icon: '🏃',
    category: AchievementCategory.fitness,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'workouts', 'value': 10},
    xpReward: 50,
    criteria: 'Log 10 Workouts',
    tag: 'ATHLETE',
  );

  static final ssbReady = Achievement(
    id: 'ssb_ready',
    name: 'SSB Ready',
    description: 'Meet all SSB fitness standards',
    icon: '🎖️',
    category: AchievementCategory.fitness,
    rarity: AchievementRarity.epic,
    unlockCondition: {'type': 'ssb_standards', 'value': 4}, // All 4 standards
    xpReward: 500,
    criteria: 'Pass 4/4 SSB Standards',
    tag: 'ELITE',
  );

  // === CHALLENGE ACHIEVEMENTS ===
  static final firstChallenge = Achievement(
    id: 'first_challenge',
    name: 'Mission Accepted',
    description: 'Complete your first daily challenge',
    icon: '✅',
    category: AchievementCategory.challenges,
    rarity: AchievementRarity.common,
    unlockCondition: {'type': 'challenges_completed', 'value': 1},
    xpReward: 10,
    criteria: 'Complete 1 Daily Challenge',
    tag: 'INITIATIVE',
  );

  static final challenge7Day = Achievement(
    id: 'challenge_7day',
    name: 'Week Warrior',
    description: 'Complete challenges for 7 consecutive days',
    icon: '🔥',
    category: AchievementCategory.challenges,
    rarity: AchievementRarity.rare,
    unlockCondition: {'type': 'challenge_streak', 'value': 7},
    xpReward: 200,
    criteria: '7-Day Challenge Streak',
    tag: 'CONSISTENCY',
  );

  static final challenge30Day = Achievement(
    id: 'challenge_30day',
    name: 'Consistency King',
    description: 'Complete challenges for 30 consecutive days',
    icon: '👑',
    category: AchievementCategory.challenges,
    rarity: AchievementRarity.legendary,
    unlockCondition: {'type': 'challenge_streak', 'value': 30},
    xpReward: 1000,
    criteria: '30-Day Challenge Streak',
    tag: 'LEGEND',
  );

  // === STREAK ACHIEVEMENTS ===
  static final streak3Days = Achievement(
    id: 'streak_3',
    name: 'Getting Started',
    description: 'Maintain a 3-day app usage streak',
    icon: '🌟',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.common,
    unlockCondition: {'type': 'login_streak', 'value': 3},
    xpReward: 25,
    criteria: 'Login 3 Days in a Row',
    tag: 'START',
  );

  static final streak7Days = Achievement(
    id: 'streak_7',
    name: 'Week Streak',
    description: 'Maintain a 7-day app usage streak',
    icon: '⭐',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'login_streak', 'value': 7},
    xpReward: 75,
    criteria: 'Login 7 Days in a Row',
    tag: 'WEEKLY',
  );

  static final streak30Days = Achievement(
    id: 'streak_30',
    name: 'Month Master',
    description: 'Maintain a 30-day app usage streak',
    icon: '💫',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.epic,
    unlockCondition: {'type': 'login_streak', 'value': 30},
    xpReward: 500,
    criteria: 'Login 30 Days in a Row',
    tag: 'MONTHLY',
  );

  static final streak100Days = Achievement(
    id: 'streak_100',
    name: 'Centurion',
    description: 'Maintain a 100-day app usage streak',
    icon: '🌠',
    category: AchievementCategory.streaks,
    rarity: AchievementRarity.legendary,
    unlockCondition: {'type': 'login_streak', 'value': 100},
    xpReward: 2000,
    criteria: 'Login 100 Days in a Row',
    tag: 'CENTURY',
  );

  // === LEVEL ACHIEVEMENTS ===
  static final level5 = Achievement(
    id: 'level_5',
    name: 'Cadet',
    description: 'Reach Level 5',
    icon: '🎖️',
    category: AchievementCategory.general,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'level', 'value': 5},
    xpReward: 50,
    criteria: 'Reach Level 5',
    tag: 'CADET',
  );

  static final level10 = Achievement(
    id: 'level_10',
    name: 'Lieutenant',
    description: 'Reach Level 10',
    icon: '🏅',
    category: AchievementCategory.general,
    rarity: AchievementRarity.rare,
    unlockCondition: {'type': 'level', 'value': 10},
    xpReward: 150,
    criteria: 'Reach Level 10',
    tag: 'OFFICER',
  );

  static final level25 = Achievement(
    id: 'level_25',
    name: 'Captain',
    description: 'Reach Level 25',
    icon: '⭐',
    category: AchievementCategory.general,
    rarity: AchievementRarity.epic,
    unlockCondition: {'type': 'level', 'value': 25},
    xpReward: 500,
    criteria: 'Reach Level 25',
    tag: 'COMMAND',
  );

  static final level50 = Achievement(
    id: 'level_50',
    name: 'General',
    description: 'Reach Level 50',
    icon: '🎗️',
    category: AchievementCategory.general,
    rarity: AchievementRarity.legendary,
    unlockCondition: {'type': 'level', 'value': 50},
    xpReward: 2000,
    criteria: 'Reach Level 50',
    tag: 'GENERAL',
  );

  // === HABIT ACHIEVEMENTS ===
  static final habitStreak7 = Achievement(
    id: 'habit_streak_7',
    name: 'Habit Former',
    description: 'Complete all habits for 7 consecutive days',
    icon: '✨',
    category: AchievementCategory.general,
    rarity: AchievementRarity.rare,
    unlockCondition: {'type': 'habit_streak', 'value': 7},
    xpReward: 200,
    criteria: '7-Day All Habits Streak',
    tag: 'HABIT',
  );

  static final habitStreak30 = Achievement(
    id: 'habit_streak_30',
    name: 'Discipline Master',
    description: 'Complete all habits for 30 consecutive days',
    icon: '🏆',
    category: AchievementCategory.general,
    rarity: AchievementRarity.legendary,
    unlockCondition: {'type': 'habit_streak', 'value': 30},
    xpReward: 1000,
    criteria: '30-Day All Habits Streak',
    tag: 'NINJA',
  );

  // === SPECIAL ACHIEVEMENTS ===
  static final earlyBird = Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Study before 6 AM',
    icon: '🌅',
    category: AchievementCategory.study,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'study_before_6am', 'value': 1},
    xpReward: 50,
    criteria: 'Log Study Session < 6 AM',
    tag: 'MORNING',
  );

  static final nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Study after 11 PM',
    icon: '🦉',
    category: AchievementCategory.study,
    rarity: AchievementRarity.uncommon,
    unlockCondition: {'type': 'study_after_11pm', 'value': 1},
    xpReward: 50,
    criteria: 'Log Study Session > 11 PM',
    tag: 'NIGHT',
  );

  static final perfectWeek = Achievement(
    id: 'perfect_week',
    name: 'Perfect Week',
    description: 'Complete all weekly goals',
    icon: '💯',
    category: AchievementCategory.general,
    rarity: AchievementRarity.rare,
    unlockCondition: {'type': 'perfect_week', 'value': 1},
    xpReward: 150,
    criteria: '100% Weekly Goals Met',
    tag: 'PERFECT',
  );

  // Get all achievements
  static List<Achievement> getAllAchievements() {
    return [
      // Study
      studyNewbie,
      study10Hours,
      study50Hours,
      study100Hours,
      
      // Fitness
      firstWorkout,
      fitness10Workouts,
      ssbReady,
      
      // Challenges
      firstChallenge,
      challenge7Day,
      challenge30Day,
      
      // Streaks
      streak3Days,
      streak7Days,
      streak30Days,
      streak100Days,
      
      // Levels
      level5,
      level10,
      level25,
      level50,
      
      // Habits
      habitStreak7,
      habitStreak30,
      
      // Special
      earlyBird,
      nightOwl,
      perfectWeek,
    ];
  }

  // Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllAchievements().where((a) => a.category == category).toList();
  }

  // Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

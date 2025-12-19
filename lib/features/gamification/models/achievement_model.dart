import 'package:cloud_firestore/cloud_firestore.dart';

/// Achievement Model - Unlockable badges for accomplishments
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji or icon name
  final AchievementCategory category;
  final AchievementRarity rarity;
  final Map<String, dynamic> unlockCondition; // e.g., {'type': 'study_hours', 'value': 100}
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String criteria; // Dynamic text e.g., "Log 10 workouts"
  final String tag;      // Tag e.g., "FITNESS", "SPEED"

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.unlockCondition,
    this.xpReward = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.criteria = 'Complete the objective',
    this.tag = 'GENERAL',
  });

  // Convert from Firestore
  factory Achievement.fromFirestore(Map<String, dynamic> data, String id) {
    return Achievement(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🏆',
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => AchievementCategory.general,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == data['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      unlockCondition: data['unlockCondition'] ?? {},
      xpReward: data['xpReward'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
      criteria: data['criteria'] ?? 'Complete the objective',
      tag: data['tag'] ?? 'GENERAL',
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.toString(),
      'rarity': rarity.toString(),
      'unlockCondition': unlockCondition,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'criteria': criteria,
      'tag': tag,
    };
  }

  // Get rarity color
  String getRarityColor() {
    switch (rarity) {
      case AchievementRarity.common:
        return '#95A5A6'; // Gray
      case AchievementRarity.uncommon:
        return '#27AE60'; // Green
      case AchievementRarity.rare:
        return '#3498DB'; // Blue
      case AchievementRarity.epic:
        return '#9B59B6'; // Purple
      case AchievementRarity.legendary:
        return '#F39C12'; // Gold
    }
  }

  // Get rarity name
  String getRarityName() {
    switch (rarity) {
      case AchievementRarity.common:
        return 'COMMON';
      case AchievementRarity.uncommon:
        return 'UNCOMMON';
      case AchievementRarity.rare:
        return 'RARE';
      case AchievementRarity.epic:
        return 'EPIC';
      case AchievementRarity.legendary:
        return 'LEGENDARY';
    }
  }

  // Copy with
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementRarity? rarity,
    Map<String, dynamic>? unlockCondition,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? criteria,
    String? tag,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      criteria: criteria ?? this.criteria,
      tag: tag ?? this.tag,
    );
  }
}

/// Achievement Categories
enum AchievementCategory {
  study,      // Study-related achievements
  fitness,    // Fitness achievements
  challenges, // Daily challenge achievements
  streaks,    // Streak achievements
  mastery,    // Subject mastery
  general,    // General achievements
}

/// Achievement Rarity Tiers
enum AchievementRarity {
  common,     // Easy to unlock
  uncommon,   // Moderate effort
  rare,       // Significant effort
  epic,       // Major accomplishment
  legendary,  // Exceptional achievement
}

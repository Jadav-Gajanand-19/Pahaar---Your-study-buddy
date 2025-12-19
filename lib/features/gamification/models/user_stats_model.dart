import 'package:cloud_firestore/cloud_firestore.dart';

/// User Statistics Model - Tracks XP, level, and other gamification stats
class UserStats {
  final String userId;
  final int xp;
  final int level;

  UserStats({
    required this.userId,
    required this.xp,
    required this.level,
  });

  factory UserStats.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserStats(
      userId: data['userId'] ?? '',
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'xp': xp,
      'level': level,
    };
  }

  UserStats copyWith({
    String? userId,
    int? xp,
    int? level,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }
}

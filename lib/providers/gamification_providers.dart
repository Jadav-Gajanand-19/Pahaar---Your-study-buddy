import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/features/gamification/models/leaderboard_model.dart';
import 'package:prahar/features/gamification/models/user_stats_model.dart';
import 'package:prahar/providers/firestore_providers.dart';

// User Stats Provider
final userStatsProvider = StreamProvider.family<UserStats?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserStatsStream(userId);
});

// Leaderboard Provider
final leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, Map<String, dynamic>>((ref, params) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final category = params['category'] as LeaderboardCategory;
  final period = params['period'] as LeaderboardPeriod;
  
  return firestoreService.getLeaderboard(
    category: category,
    period: period,
  );
});

// Achievement IDs Provider
final unlockedAchievementsProvider = StreamProvider.family<List<String>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUnlockedAchievementIds(userId);
});

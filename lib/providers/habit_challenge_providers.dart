import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/models/habit_challenge_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/midnight_refresh_provider.dart';

/// Provider for habit challenges stream
final habitChallengesProvider = StreamProvider.autoDispose<List<HabitChallenge>>((ref) {
  // Watch current date to refresh at midnight (updates current day number)
  ref.watch(currentDateProvider);
  
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(firestoreServiceProvider).getHabitChallenges(user.uid);
});

/// Provider for active habit challenges (not yet completed)
final activeHabitChallengesProvider = Provider.autoDispose<List<HabitChallenge>>((ref) {
  final challenges = ref.watch(habitChallengesProvider).value ?? [];
  return challenges.where((challenge) => challenge.isActive && !challenge.isCompleted).toList();
});

/// Provider for completed habit challenges
final completedHabitChallengesProvider = Provider.autoDispose<List<HabitChallenge>>((ref) {
  final challenges = ref.watch(habitChallengesProvider).value ?? [];
  return challenges.where((challenge) => challenge.isCompleted).toList();
});

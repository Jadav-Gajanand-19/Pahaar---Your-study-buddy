import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/services/study_recommendation_service.dart';
import 'package:prahar/providers/firestore_providers.dart';

/// Provider for Study Recommendation Service
final studyRecommendationServiceProvider = Provider<StudyRecommendationService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return StudyRecommendationService(firestoreService);
});

/// Provider for study recommendations for a specific user
final studyRecommendationsProvider = FutureProvider.family<List<StudyRecommendation>, String>((ref, userId) async {
  final service = ref.watch(studyRecommendationServiceProvider);
  return service.getRecommendations(userId);
});

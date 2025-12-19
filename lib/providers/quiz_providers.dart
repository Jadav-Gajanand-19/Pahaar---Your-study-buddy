import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/features/quiz/models/question_model.dart';
import 'package:prahar/providers/firestore_providers.dart';

final quizQuestionsProvider = FutureProvider.family<List<Question>, Map<String, dynamic>>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final subject = params['subject'] as CDSSubject;
  final difficulty = params['difficulty'] as DifficultyLevel;
  final limit = params['limit'] as int? ?? 10;
  
  return firestoreService.getQuestions(
    subject: subject,
    difficulty: difficulty,
    limit: limit,
  );
});

final userQuizSessionsProvider = StreamProvider.family<List<QuizSession>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return firestoreService.getUserQuizSessions(userId);
});

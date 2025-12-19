import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/quiz/models/question_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/quiz_providers.dart';

/// Quiz Session Screen - Take a quiz with MCQ questions
class QuizSessionScreen extends ConsumerStatefulWidget {
  final CDSSubject subject;
  final DifficultyLevel difficulty;
  final int questionCount;

  const QuizSessionScreen({
    super.key,
    required this.subject,
    required this.difficulty,
    this.questionCount = 10,
  });

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _userAnswers = {};
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider({
      'subject': widget.subject,
      'difficulty': widget.difficulty,
      'limit': widget.questionCount,
    }));

    return Scaffold(
      backgroundColor: kBackgroundBlack,
      appBar: AppBar(
        title: Text(
          '${widget.subject.displayName} Quiz',
          style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 64, color: kTextDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'No questions found',
                    style: AppTextStyles.bodyLarge.copyWith(color: kTextSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different subject or difficulty.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }
          return _buildQuizContent(questions);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: kCommandGold)),
        error: (error, stack) => Center(
          child: Text('Error loading questions: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildQuizContent(List<Question> questions) {
    final currentQuestion = questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final progress = (_currentQuestionIndex + 1) / questions.length;

    // Use a Stack to overlay the progress info on the AppBar or just keep the structure logic here
    // Replicating the previous structure but wrapped in the content builder
    
    return Column(
        children: [
          // Custom Progress Header inserted here since AppBar is static
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 Text(
                    '${_currentQuestionIndex + 1}/${questions.length}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: kCommandGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
               ],
             ),
          ),
          
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kCardElevated,
            valueColor: AlwaysStoppedAnimation<Color>(kCommandGold),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getDifficultyColor()),
                    ),
                    child: Text(
                      widget.difficulty.militaryName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getDifficultyColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Text
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppGradients.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderSubtle),
                    ),
                    child: Text(
                      currentQuestion.questionText,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final optionIndex = entry.key;
                    final optionText = entry.value;
                    final isSelected = _userAnswers[currentQuestion.id] == optionIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(
                        optionText,
                        optionIndex,
                        isSelected,
                        currentQuestion.id!,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: const Text('PREVIOUS'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _userAnswers.containsKey(currentQuestion.id)
                        ? (isLastQuestion ? () => _finishQuiz(questions) : () => _nextQuestion(questions.length))
                        : null,
                    child: Text(isLastQuestion ? 'FINISH' : 'NEXT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildOptionButton(String text, int index, bool isSelected, String questionId) {
    return InkWell(
      onTap: () {
        setState(() {
          _userAnswers[questionId] = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.goldAccent : null,
          color: isSelected ? null : kCardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kCommandGold : kBorderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : kCardElevated,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : kTextPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.black : kTextPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case DifficultyLevel.easy:
        return kMilitaryGreen;
      case DifficultyLevel.medium:
        return kStatusWarning;
      case DifficultyLevel.hard:
        return kStatusPriority;
    }
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz(List<Question> questions) {
    // Calculate score
    int correctCount = 0;
    for (var question in questions) {
      if (_userAnswers.containsKey(question.id)) {
        if (question.isCorrect(_userAnswers[question.id]!)) {
          correctCount++;
        }
      }
    }

    // Navigate to results screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          questions: questions,
          userAnswers: _userAnswers,
          correctCount: correctCount,
          totalQuestions: questions.length,
          timeTaken: DateTime.now().difference(_startTime!),
          subject: widget.subject,
          difficulty: widget.difficulty,
        ),
      ),
    );
  }
}

/// Quiz Result Screen - Show quiz results
class QuizResultScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<String, int> userAnswers;
  final int correctCount;
  final int totalQuestions;
  final Duration timeTaken;
  final CDSSubject subject;
  final DifficultyLevel difficulty;

  const QuizResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeTaken,
    required this.subject,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (correctCount / totalQuestions * 100).toInt();
    final isPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: kBackgroundBlack,
      appBar: AppBar(
        title: Text(
          'QUIZ RESULTS',
          style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isPassed ? AppGradients.activeStatus : AppGradients.priority,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPassed ? kMilitaryGreen : kStatusPriority,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.military_tech : Icons.info_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'MISSION SUCCESS!' : 'NEEDS IMPROVEMENT',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$percentage%',
                    style: AppTextStyles.countdown.copyWith(
                      fontSize: 72,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$correctCount / $totalQuestions correct',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Time: ${timeTaken.inMinutes}m ${timeTaken.inSeconds % 60}s',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(child: _buildStatCard('Attempted', '${userAnswers.length}', Icons.quiz)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Correct', '$correctCount', Icons.check_circle)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Incorrect', '${totalQuestions - correctCount}', Icons.cancel)),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('RETURN TO DASHBOARD'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Retry quiz
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => QuizSessionScreen(
                        subject: subject,
                        difficulty: difficulty,
                        questionCount: totalQuestions,
                      ),
                    ),
                  );
                },
                child: const Text('RETRY QUIZ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: kCommandGold, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

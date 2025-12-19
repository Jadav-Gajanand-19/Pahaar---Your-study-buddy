import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/quiz/models/question_model.dart';
import 'package:prahar/features/quiz/screens/quiz_session_screen.dart';

/// Quiz Selection Screen - Choose subject, difficulty, and question count
class QuizSelectionScreen extends ConsumerStatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  ConsumerState<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends ConsumerState<QuizSelectionScreen> {
  CDSSubject selectedSubject = CDSSubject.english;
  DifficultyLevel selectedDifficulty = DifficultyLevel.medium;
  int selectedQuestionCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        title: Text(
          'TACTICAL ASSESSMENT',
          style: AppTextStyles.militaryHeading.copyWith(fontSize: 18),
        ),
        backgroundColor: kCommandGold,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCommandGold, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz, color: kCommandGold, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREPARE FOR BATTLE',
                          style: AppTextStyles.militaryHeading.copyWith(
                            fontSize: 16,
                            color: kCommandGold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure your assessment parameters',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subject Selection
            _buildSectionHeader('SELECT SUBJECT'),
            const SizedBox(height: 12),
            _buildSubjectGrid(),

            const SizedBox(height: 24),

            // Difficulty Selection
            _buildSectionHeader('DIFFICULTY LEVEL'),
            const SizedBox(height: 12),
            _buildDifficultySelector(),

            const SizedBox(height: 24),

            // Question Count
            _buildSectionHeader('NUMBER OF QUESTIONS'),
            const SizedBox(height: 12),
            _buildQuestionCountSelector(),

            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCommandGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'START ASSESSMENT',
                      style: AppTextStyles.militaryHeading.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppGradients.goldAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.militaryHeading.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: CDSSubject.values.map((subject) {
        final isSelected = selectedSubject == subject;
        return GestureDetector(
          onTap: () => setState(() => selectedSubject = subject),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kCommandGold : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? kCommandGold : kBorderSubtle,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: kCommandGold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getSubjectIcon(subject),
                  color: isSelected ? Colors.white : kCommandGold,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _getSubjectName(subject),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: DifficultyLevel.values.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => selectedDifficulty = difficulty),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? _getDifficultyColor(difficulty) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _getDifficultyColor(difficulty) : kBorderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getDifficultyIcon(difficulty),
                      color: isSelected ? Colors.white : _getDifficultyColor(difficulty),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDifficultyName(difficulty),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : kTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    final counts = [5, 10, 15, 20, 25];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: counts.map((count) {
        final isSelected = selectedQuestionCount == count;
        return GestureDetector(
          onTap: () => setState(() => selectedQuestionCount = count),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? kCommandGold : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? kCommandGold : kBorderSubtle,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : kTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSessionScreen(
          subject: selectedSubject,
          difficulty: selectedDifficulty,
          questionCount: selectedQuestionCount,
        ),
      ),
    );
  }

  IconData _getSubjectIcon(CDSSubject subject) {
    switch (subject) {
      case CDSSubject.english:
        return Icons.language;
      case CDSSubject.gk:
        return Icons.public;
      case CDSSubject.math:
        return Icons.calculate;
    }
  }

  String _getSubjectName(CDSSubject subject) {
    switch (subject) {
      case CDSSubject.english:
        return 'English';
      case CDSSubject.gk:
        return 'GK';
      case CDSSubject.math:
        return 'Math';
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.trending_down;
      case DifficultyLevel.medium:
        return Icons.trending_flat;
      case DifficultyLevel.hard:
        return Icons.trending_up;
    }
  }

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return kStatusActive;
      case DifficultyLevel.medium:
        return kStatusWarning;
      case DifficultyLevel.hard:
        return kStatusError;
    }
  }
}

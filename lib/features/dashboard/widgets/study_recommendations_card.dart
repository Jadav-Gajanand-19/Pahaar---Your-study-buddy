import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/core/services/study_recommendation_service.dart';
import 'package:prahar/providers/study_recommendation_providers.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/features/tracking/screens/study_timer_screen.dart';

/// Study Recommendations Widget - Shows smart study suggestions
class StudyRecommendationsCard extends ConsumerWidget {
  const StudyRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangeProvider).value;
    
    if (user == null) return const SizedBox.shrink();

    final recommendationsAsync = ref.watch(studyRecommendationsProvider(user.uid));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCommandGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kCommandGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: kCommandGold, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'SMART STUDY SUGGESTIONS',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recommendationsAsync.when(
            data: (recommendations) {
              if (recommendations.isEmpty) {
                return Text(
                  'Complete some quizzes to get personalized recommendations',
                  style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
                );
              }

              return Column(
                children: recommendations.take(3).map((rec) => _buildRecommendationTile(context, rec)).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: kCommandGold),
              ),
            ),
            error: (e, _) => Text(
              'Unable to load recommendations',
              style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(BuildContext context, StudyRecommendation rec) {
    Color priorityColor;
    switch (rec.priorityLabel) {
      case 'HIGH':
        priorityColor = kStatusPriority;
        break;
      case 'MEDIUM':
        priorityColor = kCommandGold;
        break;
      default:
        priorityColor = kTextSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderSubtle),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to study timer with this topic
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StudyTimerScreen(),
            ),
          );
        },
        child: Row(
          children: [
            Text(rec.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.topic,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                  Text(
                    rec.reason,
                    style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    rec.priorityLabel,
                    style: GoogleFonts.oswald(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${rec.estimatedMinutes}min',
                  style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

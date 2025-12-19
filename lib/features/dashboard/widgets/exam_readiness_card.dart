import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/automation_enhancement_providers.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/settings_providers.dart';

/// Exam Readiness Card - Shows overall exam preparation status
class ExamReadinessCard extends ConsumerWidget {
  const ExamReadinessCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangeProvider).value;
    final settings = ref.watch(userSettingsProvider).value;
    
    if (user == null || settings == null) return const SizedBox.shrink();

    final examDate = settings.examDate ?? DateTime.now().add(const Duration(days: 180));
    final readinessAsync = ref.watch(examReadinessProvider((userId: user.uid, examDate: examDate)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.activeStatus,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kMilitaryGreen.withOpacity(0.5), width: 2),
      ),
      child: readinessAsync.when(
        data: (readiness) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXAM READINESS',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          readiness.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${readiness.overall}%',
                          style: AppTextStyles.countdown.copyWith(fontSize: 48, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    readiness.readinessLevel,
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Component Breakdown
            Row(
              children: [
                Expanded(child: _buildComponentBar('Study', readiness.studyReadiness)),
                const SizedBox(width: 8),
                Expanded(child: _buildComponentBar('Quiz', readiness.knowledgeReadiness)),
                const SizedBox(width: 8),
                Expanded(child: _buildComponentBar('Fitness', readiness.fitnessReadiness)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Days Remaining
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${readiness.daysUntilExam} days until exam',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Recommendations
            if (readiness.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...readiness.recommendations.take(2).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  rec,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              )),
            ],
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Unable to calculate readiness',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildComponentBar(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value%',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

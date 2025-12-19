import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/automation_enhancement_providers.dart';
import 'package:prahar/providers/auth_providers.dart';

/// Weekly Performance Summary Card
class WeeklyPerformanceCard extends ConsumerWidget {
  const WeeklyPerformanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangeProvider).value;
    
    if (user == null) return const SizedBox.shrink();

    final reportAsync = ref.watch(currentWeekReportProvider(user.uid));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: kCommandGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'THIS WEEK\'S PERFORMANCE',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reportAsync.when(
            data: (report) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Study', '${report.totalStudyMinutes}min', Icons.book),
                    _buildStat('Workouts', '${report.totalWorkouts}', Icons.fitness_center),
                    _buildStat('Grade', report.performanceGrade, Icons.grade),
                  ],
                ),
                if (report.insights.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: kBorderSubtle),
                  const SizedBox(height: 8),
                  ...report.insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      insight,
                      style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                    ),
                  )),
                ],
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: kCommandGold),
              ),
            ),
            error: (e, _) => Text(
              'Unable to load weekly report',
              style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kCommandGold, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.oswald(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
        ),
      ],
    );
  }
}

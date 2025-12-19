import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/features/dashboard/screens/weekly_operations_screen.dart';
import 'package:prahar/features/dashboard/widgets/daily_completion_dialog.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class WeeklyGoalsCard extends ConsumerWidget {
  const WeeklyGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(weeklyGoalsProvider);
    final user = ref.read(authStateChangeProvider).value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: goalsAsync.when(
          data: (goals) {
            // Calculate overall progress considering both single and daily goals
            final totalProgress = goals.fold<double>(0.0, (sum, g) => sum + g.getCompletionProgress());
            final totalCount = goals.length;
            final progress = totalCount > 0 ? totalProgress / totalCount : 0.0;
            final completedCount = goals.where((g) => g.isFullyCompleted()).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY OBJECTIVE',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: kTextSecondary,
                            fontSize: 12,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mission Completion',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: totalCount > 0 && progress == 1.0
                            ? kMilitaryGreen
                            : kCardElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$completedCount / $totalCount DONE',
                        style: AppTextStyles.statusBadge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                if (totalCount > 0) ...[
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: kCardElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.activeStatus,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Goals List
                  ...goals.map((goal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          if (user != null && goal.id != null) {
                            if (goal.goalType == GoalType.daily) {
                              // Show daily completion dialog
                              showDialog(
                                context: context,
                                builder: (context) => DailyCompletionDialog(goal: goal),
                              );
                            } else {
                              // Single goal - toggle completion directly
                              ref.read(firestoreServiceProvider).updateWeeklyGoalStatus(
                                user.uid,
                                goal.id!,
                                !goal.isCompleted,
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: goal.isCompleted
                                ? kCardElevated.withOpacity(0.5)
                                : kCardElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                goal.isFullyCompleted()
                                    ? Icons.check_circle
                                    : (goal.goalType == GoalType.daily
                                        ? Icons.calendar_today
                                        : Icons.radio_button_unchecked),
                                color: goal.isFullyCompleted()
                                    ? kMilitaryGreen
                                    : kTextDisabled,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        decoration: goal.isFullyCompleted()
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: goal.isFullyCompleted()
                                            ? kTextDisabled
                                            : kTextPrimary,
                                      ),
                                    ),
                                    if (goal.goalType == GoalType.daily) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${goal.getCompletedDaysCount()}/7 days',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: kTextSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.military_tech_outlined,
                            color: kTextDisabled,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No objectives assigned",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Manage Button - Always visible
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WeeklyOperationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('MANAGE OBJECTIVES'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(
                color: kCommandGold,
              ),
            ),
          ),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Error loading objectives: $e",
              style: AppTextStyles.bodySmall.copyWith(color: kStatusPriority),
            ),
          ),
        ),
      ),
    );
  }
}
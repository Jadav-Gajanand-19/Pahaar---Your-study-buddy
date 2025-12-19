import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/habit_challenge_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/habit_challenge_providers.dart';
import 'package:prahar/features/dashboard/widgets/add_habit_challenge_dialog.dart';
import 'package:prahar/features/dashboard/widgets/habit_challenge_success_dialog.dart';

/// Widget that displays active habit challenges on the dashboard
class HabitChallengeCard extends ConsumerWidget {
  const HabitChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(habitChallengesProvider);
    final user = ref.watch(authStateChangeProvider).value;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kCommandGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.emoji_events, color: kCommandGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HABIT CHALLENGES',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: kCommandGold, size: 24),
                onPressed: () => showAddHabitChallengeDialog(context, ref),
                tooltip: 'Create New Challenge',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Challenge List
          challengesAsync.when(
            data: (challenges) {
              final activeChallenges = challenges.where((c) => c.isActive && !c.isCompleted).toList();
              
              if (activeChallenges.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.flag_outlined, color: kTextDisabled, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No active challenges',
                          style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to create a 30 or 60-day challenge',
                          style: AppTextStyles.bodySmall.copyWith(color: kTextDisabled),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 320, // Fixed height for swipeable area
                child: PageView.builder(
                  itemCount: activeChallenges.length,
                  controller: PageController(viewportFraction: 0.92),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChallengeItem(
                        challenge: activeChallenges[index],
                        userId: user?.uid ?? '',
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: kCommandGold),
              ),
            ),
            error: (e, _) => Text(
              'Unable to load challenges',
              style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual challenge item widget
class _ChallengeItem extends ConsumerWidget {
  final HabitChallenge challenge;
  final String userId;

  const _ChallengeItem({
    required this.challenge,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDay = challenge.getCurrentDayNumber();
    final progress = challenge.completionPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Title and Duration Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kCommandGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: kCommandGold),
                ),
                child: Text(
                  '${challenge.duration}D',
                  style: GoogleFonts.oswald(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kCommandGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $currentDay/${challenge.duration}',
                style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
              ),
              Text(
                '${challenge.completedDays}/${challenge.duration} completed',
                style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[700],
              color: kCommandGold,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}% Complete',
            style: AppTextStyles.bodySmall.copyWith(
              color: kCommandGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Daily Completion Grid (showing last 7 days)
          _buildWeeklyGrid(context, ref),
          
          const SizedBox(height: 12),
          
          // Delete Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Challenge?'),
                    content: Text('Are you sure you want to delete "${challenge.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && userId.isNotEmpty && challenge.id != null) {
                  ref.read(firestoreServiceProvider).deleteHabitChallenge(userId, challenge.id!);
                }
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid(BuildContext context, WidgetRef ref) {
    final currentDay = challenge.getCurrentDayNumber();
    
    // Show current week (7 days centered around current day)
    final startDay = (currentDay - 3).clamp(1, challenge.duration);
    final endDay = (startDay + 6).clamp(1, challenge.duration);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(endDay - startDay + 1, (index) {
        final dayNumber = startDay + index;
        final isCompleted = challenge.dailyCompletions[dayNumber] ?? false;
        final isToday = dayNumber == currentDay;
        
        // Check if day is in the past or future
        final isPast = dayNumber < currentDay;
        final isFuture = dayNumber > currentDay;
        final isLocked = isPast || isFuture;
        
        return _DayCircle(
          dayNumber: dayNumber,
          isCompleted: isCompleted,
          isToday: isToday,
          isLocked: isLocked,
          isPast: isPast,
          onTap: () async {
            // Only allow toggling today's day
            if (!isToday) {
              // Show a message that only today can be logged
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isLocked
                        ? (isPast ? 'Past days cannot be modified' : 'Future days cannot be logged')
                        : 'Only today can be logged',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red[700],
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            
            if (userId.isNotEmpty && challenge.id != null) {
              // Update the completion status
              await ref.read(firestoreServiceProvider).updateHabitChallengeCompletion(
                userId,
                challenge.id!,
                dayNumber,
                !isCompleted,
              );
              
              // If we just completed today (changed from false to true), show success dialog
              if (!isCompleted && context.mounted) {
                showHabitChallengeSuccessDialog(context);
              }
            }
          },
        );
      }),
    );
  }
}

/// Day circle widget for daily completion tracking
class _DayCircle extends StatelessWidget {
  final int dayNumber;
  final bool isCompleted;
  final bool isToday;
  final bool isLocked;
  final bool isPast;
  final VoidCallback onTap;

  const _DayCircle({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
    required this.isLocked,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: isLocked && !isCompleted ? 0.4 : 1.0,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? kMilitaryGreen
                : (isToday ? kCommandGold.withOpacity(0.2) : Colors.grey[800]),
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? kCommandGold : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '$dayNumber',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isToday ? kCommandGold : kTextSecondary,
                        ),
                      ),
              ),
              // Show lock icon for past non-completed days
              if (isLocked && !isCompleted)
                Center(
                  child: Icon(
                    isPast ? Icons.lock : Icons.lock_clock,
                    color: Colors.white.withOpacity(0.6),
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

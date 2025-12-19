import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class DailyCompletionDialog extends ConsumerWidget {
  final WeeklyGoal goal;

  const DailyCompletionDialog({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateChangeProvider).value;
    if (user == null) return const SizedBox();

    // Get the start of the current week (Sunday)
    final now = DateTime.now();
    final daysToSubtract = now.weekday % 7; // 0 = Sunday
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));

    // Days of the week
    final weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kMilitaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, color: kMilitaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY TRACKING',
                        style: GoogleFonts.oswald(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: kTextDarkSecondary,
                        ),
                      ),
                      Text(
                        goal.title,
                        style: GoogleFonts.oswald(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextDarkPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kLightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROGRESS',
                    style: GoogleFonts.oswald(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: kTextDarkSecondary,
                    ),
                  ),
                  Text(
                    '${goal.getCompletedDaysCount()}/7 DAYS',
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kMilitaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Week View
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final dayDate = startOfWeek.add(Duration(days: index));
                final isToday = WeeklyGoal.isToday(dayDate);
                final isPast = WeeklyGoal.isPast(dayDate);
                final isFuture = WeeklyGoal.isFuture(dayDate);
                final isCompleted = goal.isDayCompleted(index);
                final canToggle = isToday;

                return Expanded(
                  child: GestureDetector(
                    onTap: canToggle
                        ? () {
                            ref.read(firestoreServiceProvider).updateDailyGoalCompletion(
                                  user.uid,
                                  goal.id!,
                                  index,
                                  !isCompleted,
                                );
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          // Day label
                          Text(
                            weekDays[index],
                            style: GoogleFonts.oswald(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isToday ? kMilitaryGreen : kTextDarkSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? kMilitaryGreen
                                  : (isFuture
                                      ? Colors.grey[200]
                                      : Colors.white),
                              border: Border.all(
                                color: isToday
                                    ? kMilitaryGreen
                                    : (isCompleted
                                        ? kMilitaryGreen
                                        : Colors.grey[300]!),
                                width: isToday ? 2 : 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : (isFuture
                                      ? Icon(Icons.lock_outline, color: Colors.grey[400], size: 16)
                                      : null),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Status label
                          Text(
                            isToday
                                ? 'TODAY'
                                : (isPast
                                    ? (isCompleted ? 'DONE' : '')
                                    : ''),
                            style: GoogleFonts.oswald(
                              fontSize: 8,
                              color: isToday ? kMilitaryGreen : kTextDarkSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCommandGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kCommandGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: kCommandGold.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap today\'s circle to mark complete. Past and future days are locked.',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: kTextDarkPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: kMilitaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'DONE',
                  style: GoogleFonts.oswald(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

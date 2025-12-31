import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class DailyCompletionDialog extends ConsumerStatefulWidget {
  final WeeklyGoal goal;

  const DailyCompletionDialog({super.key, required this.goal});

  @override
  ConsumerState<DailyCompletionDialog> createState() => _DailyCompletionDialogState();
}

class _DailyCompletionDialogState extends ConsumerState<DailyCompletionDialog> 
    with TickerProviderStateMixin {
  // Track which day is currently animating
  int? _animatingDayIndex;
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for the bounce effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Checkmark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _onDayTapped(int dayIndex, bool isCurrentlyCompleted) {
    final user = ref.read(authStateChangeProvider).value;
    if (user == null) return;

    setState(() {
      _animatingDayIndex = dayIndex;
    });

    // Play scale animation
    _scaleController.forward(from: 0);

    // If marking as complete, play the check animation
    if (!isCurrentlyCompleted) {
      _checkController.forward(from: 0);
    } else {
      _checkController.reverse(from: 1);
    }

    // Update Firestore
    ref.read(firestoreServiceProvider).updateDailyGoalCompletion(
      user.uid,
      widget.goal.id!,
      dayIndex,
      !isCurrentlyCompleted,
    );

    // Reset animating index after animation completes
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _animatingDayIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authStateChangeProvider).value;
    if (user == null) return const SizedBox();

    // Watch for goal updates to get real-time completion status
    final goalsAsync = ref.watch(weeklyGoalsProvider);
    
    // Get the current goal state (might be updated)
    final currentGoal = goalsAsync.whenOrNull(
      data: (goals) => goals.firstWhere(
        (g) => g.id == widget.goal.id,
        orElse: () => widget.goal,
      ),
    ) ?? widget.goal;

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
                        currentGoal.title,
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
                    '${currentGoal.getCompletedDaysCount()}/7 DAYS',
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
                final isCompleted = currentGoal.isDayCompleted(index);
                // Only today can be toggled - days unlock at midnight
                final canToggle = isToday;
                final isAnimating = _animatingDayIndex == index;
                
                // Determine colors based on state
                Color circleColor;
                Color borderColor;
                Color? iconColor;
                IconData? icon;
                List<BoxShadow>? shadow;
                
                if (isCompleted) {
                  // Completed - Green
                  circleColor = kMilitaryGreen;
                  borderColor = kMilitaryGreen;
                  iconColor = Colors.white;
                  icon = Icons.check;
                  shadow = [
                    BoxShadow(
                      color: kMilitaryGreen.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ];
                } else if (isPast) {
                  // Past and not completed - Red (missed)
                  circleColor = Colors.red.shade400;
                  borderColor = Colors.red.shade400;
                  iconColor = Colors.white;
                  icon = Icons.close;
                  shadow = [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ];
                } else if (isFuture) {
                  // Future - Locked (grey)
                  circleColor = Colors.grey[200]!;
                  borderColor = Colors.grey[300]!;
                  iconColor = Colors.grey[400];
                  icon = Icons.lock_outline;
                  shadow = null;
                } else {
                  // Today and not completed - White with green border
                  circleColor = Colors.white;
                  borderColor = kMilitaryGreen;
                  iconColor = null;
                  icon = null;
                  shadow = null;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: canToggle
                        ? () => _onDayTapped(index, isCompleted)
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
                              color: isToday 
                                  ? kMilitaryGreen 
                                  : (isPast && !isCompleted 
                                      ? Colors.red.shade400 
                                      : kTextDarkSecondary),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day circle with animation
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isAnimating ? _scaleAnimation.value : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: circleColor,
                                    border: Border.all(
                                      color: borderColor,
                                      width: isToday ? 2 : 1,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: shadow,
                                  ),
                                  child: Center(
                                    child: icon != null
                                        ? (isCompleted && isAnimating
                                            ? _buildAnimatedCheck(isAnimating)
                                            : Icon(icon, color: iconColor, size: icon == Icons.lock_outline ? 16 : 20))
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 4),

                          // Status label
                          Text(
                            isToday
                                ? 'TODAY'
                                : (isPast
                                    ? (isCompleted ? 'DONE' : 'MISSED')
                                    : ''),
                            style: GoogleFonts.oswald(
                              fontSize: 8,
                              color: isToday 
                                  ? kMilitaryGreen 
                                  : (isPast && !isCompleted 
                                      ? Colors.red.shade400 
                                      : kTextDarkSecondary),
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
                      'Tap today to mark complete. Days unlock at midnight. Green = Done, Red = Missed.',
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

  /// Build animated checkmark icon
  Widget _buildAnimatedCheck(bool isAnimating) {
    if (isAnimating) {
      return AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _checkAnimation.value,
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          );
        },
      );
    }
    return const Icon(Icons.check, color: Colors.white, size: 20);
  }
}


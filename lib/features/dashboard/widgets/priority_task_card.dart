import 'package:flutter/material.dart';
import 'package:prahar/core/theme/theme.dart';

/// Priority Task Card with tactical color coding
/// Features: PRIORITY, WORK, ROUTINE labels
class PriorityTaskCard extends StatelessWidget {
  final String title;
  final String priority; // 'PRIORITY', 'WORK', 'ROUTINE'
  final VoidCallback? onTap;
  final bool isCompleted;

  const PriorityTaskCard({
    super.key,
    required this.title,
    this.priority = 'ROUTINE',
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, badgeLabel) = _getPriorityStyle();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priority == 'PRIORITY' ? kStatusPriority.withOpacity(0.3) : kBorderSubtle,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.statusBadge.copyWith(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 12),

                // Task Title
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCompleted ? kTextDisabled : kTextPrimary,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),

                // Status Icon
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? kMilitaryGreen : kTextDisabled,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, String) _getPriorityStyle() {
    switch (priority.toUpperCase()) {
      case 'PRIORITY':
        return (kStatusPriority, 'P');
      case 'WORK':
        return (kStatusPending, 'W');
      case 'ROUTINE':
      default:
        return (kCardElevated, 'R');
    }
  }
}

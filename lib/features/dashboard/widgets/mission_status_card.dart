import 'package:flutter/material.dart';
import 'package:prahar/core/theme/theme.dart';
import 'dart:async';

/// Mission Status Card with countdown timer to exam
/// Shows active status and days remaining
class MissionStatusCard extends StatefulWidget {
  final DateTime examDate;
  final String examName;

  const MissionStatusCard({
    super.key,
    required this.examDate,
    required this.examName,
  });

  @override
  State<MissionStatusCard> createState() => _MissionStatusCardState();
}

class _MissionStatusCardState extends State<MissionStatusCard> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    setState(() {
      _timeRemaining = widget.examDate.difference(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _timeRemaining.inDays;
    final hoursRemaining = _timeRemaining.inHours % 24;

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MISSION STATUS',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: kTextSecondary,
                    letterSpacing: 2.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppGradients.activeStatus,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTextStyles.statusBadge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Countdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$daysRemaining',
                  style: AppTextStyles.countdown.copyWith(fontSize: 48),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'DAYS',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: kCommandGold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Target Exam
            Row(
              children: [
                const Icon(Icons.calendar_today, color: kCommandGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Target: ${widget.examName}',
                    style: AppTextStyles.bodyMedium.copyWith(color: kTextPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event, color: kCommandGold, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${_formatDate(widget.examDate)} • $hoursRemaining hrs',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

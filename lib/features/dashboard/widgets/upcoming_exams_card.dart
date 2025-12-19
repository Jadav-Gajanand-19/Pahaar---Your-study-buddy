import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingExamsCard extends StatelessWidget {
  const UpcomingExamsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = {
      'Mission: CDS (I)': DateTime(2026, 4, 12),
      'Mission: AFCAT (I)': DateTime(2026, 2, 15),
    };

    final now = DateTime.now();
    MapEntry<String, DateTime>? nearestExam;
    int? minDays;

    for (var entry in exams.entries) {
      if (entry.value.isAfter(now)) {
        final daysRemaining = entry.value.difference(now).inDays;
        if (minDays == null || daysRemaining < minDays) {
          minDays = daysRemaining;
          nearestExam = entry;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming Missions", style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 20),
            if (nearestExam != null)
              _ExamCountdownTile(
                title: nearestExam.key,
                date: nearestExam.value,
                daysRemaining: minDays!,
                isPrimary: true,
              )
            else
              const Text("No upcoming missions scheduled."),
          ],
        ),
      ),
    );
  }
}

class _ExamCountdownTile extends StatelessWidget {
  const _ExamCountdownTile({
    required this.title,
    required this.date,
    required this.daysRemaining,
    this.isPrimary = false,
  });

  final String title;
  final DateTime date;
  final int daysRemaining;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: isPrimary ? 28 : 22,
        backgroundColor: isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              daysRemaining.toString(),
              style: TextStyle(
                fontSize: isPrimary ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "Days",
              style: TextStyle(
                fontSize: 10,
                color: isPrimary ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      title: Text(title, style: TextStyle(fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(DateFormat.yMMMd().format(date)),
    );
  }
}
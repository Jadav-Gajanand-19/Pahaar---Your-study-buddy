import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/models/habit_model.dart';
import 'package:prahar/features/tracking/screens/habit_tracker_screen.dart'; // To reuse the provider
import 'package:table_calendar/table_calendar.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitLogsAsync = ref.watch(habitLogsStreamProvider(habit.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
      ),
      body: habitLogsAsync.when(
        data: (logs) {
          final completedDates = logs
              .map((ts) => DateTime.utc(ts.toDate().year, ts.toDate().month, ts.toDate().day))
              .toSet();

          return Column(
            children: [
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (completedDates.contains(date)) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              // You can add more stats here later
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
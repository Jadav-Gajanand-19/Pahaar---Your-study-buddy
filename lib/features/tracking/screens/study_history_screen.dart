import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StudyHistoryScreen extends ConsumerStatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  ConsumerState<StudyHistoryScreen> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends ConsumerState<StudyHistoryScreen> {
  late final ValueNotifier<List<StudySession>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<StudySession> _getSessionsForDay(List<StudySession> allSessions, DateTime day) {
    return allSessions.where((session) => isSameDay(session.startTime, day)).toList();
  }

  // Helper method to calculate total study time per day
  Map<DateTime, int> _prepareHeatmapData(List<StudySession> allSessions) {
    final Map<DateTime, double> dailyMinutes = {};
    for (var session in allSessions) {
      final date = session.startTime;
      final day = DateTime(date.year, date.month, date.day);
      dailyMinutes[day] = (dailyMinutes[day] ?? 0) + (session.durationInSeconds / 60.0);
    }
    return dailyMinutes.map((key, value) {
      if (value < 30) return MapEntry(key, 1);
      if (value < 120) return MapEntry(key, 3);
      if (value < 240) return MapEntry(key, 5);
      if (value < 360) return MapEntry(key, 7);
      return MapEntry(key, 10);
    });
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(studySessionsForMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study History'),
      ),
      body: Column(
        children: [
          sessionsAsync.when(
            data: (sessions) {
              final heatmapData = _prepareHeatmapData(sessions);
              
              // --- NEW: Brighter, theme-consistent color set ---
              final Map<int, Color> colorsets = {
                1: theme.colorScheme.secondary.withOpacity(0.3),
                3: theme.colorScheme.secondary.withOpacity(0.7),
                5: theme.colorScheme.primary.withOpacity(0.5),
                7: theme.colorScheme.primary.withOpacity(0.8),
                10: theme.colorScheme.primary,
              };

              return TableCalendar<StudySession>(
                firstDay: DateTime.utc(2024),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) => _getSessionsForDay(sessions, day),
                onPageChanged: (focusedDay) {
                  setState(() { _focusedDay = focusedDay; });
                  ref.read(studyHistoryFocusedMonthProvider.notifier).state = focusedDay;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() { _focusedDay = focusedDay; });
                  _selectedEvents.value = _getSessionsForDay(sessions, selectedDay);
                },
                selectedDayPredicate: (day) => isSameDay(_focusedDay, day),
                calendarBuilders: CalendarBuilders(
                  // --- NEW STYLING LOGIC ---
                  defaultBuilder: (context, day, focusedDay) {
                    final intensity = heatmapData[DateTime(day.year, day.month, day.day)];
                    if (intensity != null) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: colorsets[intensity],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(child: Text('${day.day}', style: const TextStyle())),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.secondary, width: 2.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(child: Text('${day.day}', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold))),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e")),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Logs for ${DateFormat.yMMMd().format(_focusedDay)}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<StudySession>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(child: Text('No study sessions logged for this day.'));
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final session = value[index];
                    return ListTile(
                      leading: Icon(Icons.military_tech_outlined, color: theme.colorScheme.secondary),
                      title: Text(session.subject),
                      trailing: Text(_formatDuration(session.durationInSeconds)),
                      subtitle: Text(session.notes ?? 'No notes'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
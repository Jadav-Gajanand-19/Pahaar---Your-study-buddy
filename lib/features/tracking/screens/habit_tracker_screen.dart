import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/core/services/notification_service.dart';
import 'package:prahar/core/services/hybrid_notification_service.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/habit_model.dart';
import 'package:prahar/features/settings/screens/notification_settings_screen.dart';
import 'package:prahar/features/tracking/screens/habit_detail_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/automation_providers.dart';
import 'package:prahar/core/services/automation_service.dart';

final habitLogsStreamProvider = StreamProvider.family<List<Timestamp>, String>((ref, habitId) {
  final user = ref.watch(authStateChangeProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getHabitLogsForStreak(user.uid, habitId);
});

class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final todaysLogsAsync = ref.watch(todaysHabitLogsProvider);
    final theme = Theme.of(context);

    // Calculate Mission Status
    // Ideally this should be in a provider to avoid recalc on every build, but for now we do it here.
    return Scaffold(
      backgroundColor: kLightBackground,
      body: SafeArea(
        child: habitsAsync.when(
          data: (habits) {
            return todaysLogsAsync.when(
              data: (logsMap) {
                final totalHabits = habits.length;
                final completedHabits = habits.where((h) {
                   final logDoc = logsMap[h.id];
                   return logDoc != null && logDoc.exists && (logDoc.data() as Map<String, dynamic>)['isCompleted'] == true;
                }).length;
                final progress = totalHabits > 0 ? completedHabits / totalHabits : 0.0;
                final percentage = (progress * 100).toInt();

                return CustomScrollView(
                  slivers: [
                    // 1. Header & Status Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TACTICAL COMMAND',
                                      style: GoogleFonts.blackOpsOne(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: kOlivePrimary,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      'Daily Ops',
                                      style: GoogleFonts.blackOpsOne(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: kTextDarkPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat('dd MMM').format(DateTime.now()).toUpperCase(),
                                          style: GoogleFonts.blackOpsOne(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDarkPrimary),
                                        ),
                                        Text(
                                          DateFormat('HHmm a').format(DateTime.now()), 
                                          style: GoogleFonts.lato(fontSize: 12, color: kTextDarkSecondary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const NotificationSettingsScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                                        ),
                                        child: const Icon(Icons.notifications_none, color: kTextDarkPrimary),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),

                            // Mission Status Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E5128), // Dark Green from image
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: const Color(0xFF1E5128).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MISSION STATUS',
                                            style: GoogleFonts.blackOpsOne(fontSize: 12, color: Colors.white.withOpacity(0.8), letterSpacing: 1.5, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Directives Executed',
                                            style: GoogleFonts.blackOpsOne(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$percentage%',
                                        style: GoogleFonts.blackOpsOne(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF8DC63F)), // Reduced from 32
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: totalHabits > 0 ? progress : 0,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      color: const Color(0xFF8DC63F), // Lime Green
                                      minHeight: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: _StatusPill(label: '${completedHabits.toString().padLeft(2, '0')} / ${totalHabits.toString().padLeft(2, '0')} DONE', color: Colors.white.withOpacity(0.15))),
                                      const SizedBox(width: 8),
                                      Flexible(child: _StatusPill(label: 'LEFT: ${(totalHabits - completedHabits).toString().padLeft(2, '0')}', color: Colors.white.withOpacity(0.1))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Active Directives Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ACTIVE DIRECTIVES',
                              style: GoogleFonts.blackOpsOne(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDarkPrimary, letterSpacing: 1.5),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.tune, size: 16, color: kTextDarkSecondary),
                              label: Text('FILTER', style: GoogleFonts.blackOpsOne(fontSize: 12, color: kTextDarkSecondary, fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    // 3. Habits List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = habits[index];
                          final logDoc = logsMap[habit.id];
                          return HabitListItem(habit: habit, logDoc: logDoc, index: index);
                        },
                        childCount: habits.length,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: kOlivePrimary)),
              error: (err, stack) => Center(child: Text('Error loading status: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: kOlivePrimary)),
          error: (err, stack) => Center(child: Text('Error loading habits: $err')),
        ),
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1E5128), // Dark Green
          borderRadius: BorderRadius.circular(16),
           boxShadow: [BoxShadow(color: const Color(0xFF1E5128).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddOrEditHabitDialog(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.blackOpsOne(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.4), overflow: TextOverflow.ellipsis),
    );
  }
}

class HabitListItem extends ConsumerWidget {
  const HabitListItem({super.key, required this.habit, this.logDoc, required this.index});
  final Habit habit;
  final DocumentSnapshot? logDoc;
  final int index;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'physical': return Icons.directions_run;
      case 'mental': return Icons.map; // Tactical Maps
      case 'spiritual': return Icons.water_drop; // Hydration? Or Self improvement
      case 'educational': return Icons.newspaper; // Current Affairs
      case 'general': return Icons.build; // Maintenance
      default: return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateChangeProvider).value;
    final isCompleted = logDoc != null && logDoc!.exists ? (logDoc!.data() as Map<String, dynamic>)['isCompleted'] : false;

    return Dismissible(
      key: ValueKey(habit.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Abort Mission?'),
            content: Text('Delete directive "${habit.title}" from protocols?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('CONFIRM DELETE')),
            ],
          ),
        );
      },
      onDismissed: (_) {
         if (user != null) ref.read(firestoreServiceProvider).deleteHabit(user.uid, habit.id!);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // More rounded
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F6), // Very light green from image
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getCategoryIcon(habit.category), color: const Color(0xFF1E5128), size: 24),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Consumer(
                 builder: (context, ref, child) {
                   final habitLogsAsync = ref.watch(habitLogsStreamProvider(habit.id!));
                   return habitLogsAsync.when(
                     data: (logs) {
                        final streakData = calculateAdvancedStreak(logs, habit.createdAt.toDate());
                        final currentStreak = streakData['currentStreak'];
                        final longestStreak = streakData['longestStreak'];
                        final startDate = streakData['startDate'] as DateTime;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: GoogleFonts.blackOpsOne(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Stats Row
                            Row(
                              children: [
                                // Streak Badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9), // Light Green
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.local_fire_department, size: 12, color: Color(0xFF1E5128)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              text: 'Streak: ',
                                              style: GoogleFonts.lato(fontSize: 11, color: const Color(0xFF1E5128), fontWeight: FontWeight.bold),
                                              children: [
                                                TextSpan(text: '\n$currentStreak', style: const TextStyle(fontSize: 12)),
                                              ]
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height: 24, width: 1, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 8)),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Best:', style: GoogleFonts.lato(fontSize: 10, color: const Color(0xFF7F8C8D))),
                                      Text('$longestStreak', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Container(height: 24, width: 1, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 8)),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Start: ${DateFormat('dd').format(startDate)}', style: GoogleFonts.lato(fontSize: 10, color: const Color(0xFF7F8C8D)), overflow: TextOverflow.ellipsis),
                                      Text(DateFormat('MMM').format(startDate), style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                     },
                     loading: () => Text('Syncing...', style: GoogleFonts.lato(fontSize: 12)),
                     error: (_,__) => const SizedBox(),
                   );
                 }
              ),
            ),
            
            // Checkbox
            GestureDetector(
              onTap: () async {
                if (user != null) {
                   // Toggle completion
                   await ref.read(firestoreServiceProvider).toggleHabitCompletion(user.uid, habit.id!, !isCompleted, logDoc);
                   
                   // Trigger automation when completing a habit (not uncompleting)
                   if (!isCompleted) {
                     try {
                       final automationResults = await ref.read(automationServiceProvider).onHabitComplete(user.uid);
                       
                       if (automationResults.isNotEmpty && context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(AutomationService.formatResults(automationResults)),
                             duration: const Duration(seconds: 4),
                             backgroundColor: kCommandGold,
                             behavior: SnackBarBehavior.floating,
                           ),
                         );
                       }
                     } catch (e) {
                       print('Automation error: $e');
                     }
                   }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF22C55E) : Colors.transparent, // Bright Green
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted ? Colors.transparent : Colors.grey[300]!, 
                    width: 2
                  ),
                ),
                child: isCompleted 
                  ? const Icon(Icons.check, color: Colors.white, size: 28) 
                  : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keeping helper references mostly same but updating UI in dialog
void _showAddOrEditHabitDialog(BuildContext context, WidgetRef ref, {Habit? habit}) {
  final isEditing = habit != null;
  final controller = TextEditingController(text: isEditing ? habit.title : '');
  String selectedCategory = isEditing ? habit.category : 'Physical';
  TimeOfDay? selectedTime;

  if (isEditing && habit.reminderTime != null) {
      final parts = habit.reminderTime!.split(':');
      selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  
  final categories = ['Physical', 'Mental', 'Spiritual', 'Educational', 'General'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isEditing ? 'EDIT DIRECTIVE' : 'NEW DIRECTIVE',
              style: GoogleFonts.blackOpsOne(fontWeight: FontWeight.bold, color: kMilitaryGreen),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: GoogleFonts.lato(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kLightBackground,
                      hintText: 'e.g., 0500 Drill',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedCategory = value);
                    },
                    decoration: InputDecoration(
                       labelText: 'Category',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text('Reminder Protocol', style: GoogleFonts.blackOpsOne()),
                    subtitle: Text(selectedTime == null ? 'No alarm set' : selectedTime!.format(context)),
                    trailing: Icon(Icons.alarm, color: selectedTime == null ? Colors.grey : kOlivePrimary),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => selectedTime = picked);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  final user = ref.read(authStateChangeProvider).value;
                  final title = controller.text.trim();
                  if (title.isNotEmpty && user != null) {
                    final reminderTimeString = selectedTime == null ? null : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                    final notificationService = NotificationService();
                    
                    String habitId;
                    if (isEditing) {
                      await ref.read(firestoreServiceProvider).updateHabit(
                         user.uid, habit.id!,
                         title: title, category: selectedCategory, reminderTime: reminderTimeString
                      );
                      await notificationService.cancelNotification(habit.id!.hashCode);
                      habitId = habit.id!;
                    } else {
                      final newHabit = Habit(
                        title: title, category: selectedCategory, createdAt: Timestamp.now(), reminderTime: reminderTimeString
                      );
                      final docRef = await ref.read(firestoreServiceProvider).addHabit(user.uid, newHabit);
                      habitId = docRef.id;
                    }

                    if (selectedTime != null) {
                      // Schedule/Reschedule hybrid notification for critical habit reminders
                      final hybridService = ref.read(hybridNotificationServiceProvider);
                      await hybridService.scheduleHabitReminderHybrid(
                        userId: user.uid,
                        habitId: habitId.hashCode,
                        habitTitle: title,
                        reminderTime: selectedTime!,
                      );
                    }
                    if(context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kOlivePrimary, foregroundColor: Colors.white),
                child: const Text('CONFIRM'),
              ),
            ],
          );
        }
      );
    }
  );
}

// Copy of helper function
Map<String, dynamic> calculateAdvancedStreak(List<Timestamp> timestamps, DateTime habitStartDate) {
  if (timestamps.isEmpty) return {'currentStreak': 0, 'longestStreak': 0, 'startDate': habitStartDate};

  final uniqueDates = timestamps
      .map((ts) => DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day))
      .toSet().toList();
  uniqueDates.sort((a, b) => b.compareTo(a));

  int currentStreak = 0;
  DateTime effectiveStartDate = habitStartDate;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterdayDate = todayDate.subtract(const Duration(days: 1));

  if (uniqueDates.isNotEmpty && (uniqueDates.first.isAtSameMomentAs(todayDate) || uniqueDates.first.isAtSameMomentAs(yesterdayDate))) {
    currentStreak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      if (uniqueDates[i].difference(uniqueDates[i + 1]).inDays == 1) {
        currentStreak++;
      } else {
        break; 
      }
    }
    effectiveStartDate = uniqueDates.first.subtract(Duration(days: currentStreak - 1));
  } else {
    currentStreak = 0;
    effectiveStartDate = todayDate; 
  }

  int longestStreak = 0;
  if (uniqueDates.isNotEmpty) {
    int tempStreak = 1;
    longestStreak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      if (uniqueDates[i].difference(uniqueDates[i + 1]).inDays == 1) {
        tempStreak++;
      } else {
        tempStreak = 1;
      }
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }
  }
  
  return {'currentStreak': currentStreak, 'longestStreak': longestStreak, 'startDate': effectiveStartDate};
}

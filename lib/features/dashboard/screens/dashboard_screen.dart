import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prahar/features/reflection/screens/journal_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/data/models/task_model.dart';
import 'package:prahar/features/analytics/screens/intel_report_screen.dart';
import 'package:prahar/features/dashboard/widgets/daily_intel_card.dart';
import 'package:prahar/features/dashboard/widgets/mission_status_card.dart';
import 'package:prahar/features/dashboard/widgets/session_log_tile.dart';
import 'package:prahar/features/dashboard/widgets/upcoming_exams_card.dart';
import 'package:prahar/features/dashboard/widgets/weekly_goals_card.dart';
import 'package:prahar/features/dashboard/widgets/study_recommendations_card.dart';

import 'package:prahar/features/dashboard/widgets/weekly_performance_card.dart';
import 'package:prahar/features/dashboard/widgets/habit_challenge_card.dart';
import 'package:prahar/features/tracking/screens/study_timer_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/settings_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    final sessionsAsyncValue = ref.watch(todaysSessionsStreamProvider);
    final user = ref.watch(authStateChangeProvider).value;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kBackgroundBlack,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CDS PREP',
              style: AppTextStyles.cardTitle.copyWith(
                color: kCommandGold,
                fontSize: 11,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'OPERATIONS COMMAND',
              style: AppTextStyles.sectionHeader.copyWith(fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const StudyTimerScreen()),
            ),
            icon: Icon(Icons.shield, color: kCommandGold),
            tooltip: 'COMBAT MODE',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const IntelReportScreen()),
            ),
            icon: const Icon(Icons.insights, color: kCommandGold),
            tooltip: 'Combat Analytics',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const JournalScreen()),
            ),
            icon: const Icon(Icons.book, color: kCommandGold),
            tooltip: 'Daily Debrief',
          ),
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: Icon(Icons.logout, color: kTextSecondary),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Daily Intel Quote (Tap for Full Report)
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const IntelReportScreen()),
              ),
              child: const DailyIntelCard(),
            ),
          ),
          
          // Mission Status - Exam Countdown
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(userSettingsProvider).value;
                final examDate = settings?.examDate ?? DateTime.now().add(const Duration(days: 180));
                final examType = settings?.examType ?? 'CDS';
                
                return MissionStatusCard(
                  examDate: examDate,
                  examName: examType,
                );
              },
            ),
          ),
          
          // Upcoming Exams Card
          const SliverToBoxAdapter(child: UpcomingExamsCard()),
          
          // Weekly Objectives
          const SliverToBoxAdapter(child: WeeklyGoalsCard()),
          
          // Smart Study Suggestions (NEW)
          const SliverToBoxAdapter(child: StudyRecommendationsCard()),
          
          
          // Weekly Performance (NEW)
          const SliverToBoxAdapter(child: WeeklyPerformanceCard()),
          
          // Habit Challenges (30/60-Day Challenges)
          const SliverToBoxAdapter(child: HabitChallengeCard()),
          
          // Intelligence Briefing Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: AppGradients.goldAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "TODAY'S BRIEFING",
                    style: AppTextStyles.sectionHeader,
                  ),
                ],
              ),
            ),
          ),
          tasksAsyncValue.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: AppGradients.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderSubtle),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: kTextDisabled,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No active missions",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    final daysSinceCreation = DateTime.now().difference(task.createdAt.toDate()).inDays;
                    final bool isMissed = daysSinceCreation > 2;

                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: task.isCompleted
                              ? const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                )
                              : AppGradients.activeStatus,
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          task.isCompleted
                              ? Icons.remove_done_outlined
                              : Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.priority,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_forever, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          final bool? shouldToggle = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(task.isCompleted ? 'Mark as Pending?' : 'Mark as Completed?'),
                              content: const Text('Do you want to change the status of this task?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
                              ],
                            ),
                          );
                          if (shouldToggle == true && user != null && task.id != null) {
                            ref.read(firestoreServiceProvider).updateTaskStatus(user.uid, task.id!, !task.isCompleted);
                          }
                          return false;
                        } else {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete the task "${task.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                              ],
                            ),
                          );
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart && user != null && task.id != null) {
                          ref.read(firestoreServiceProvider).deleteTask(user.uid, task.id!);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: kCardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMissed
                                ? kStatusPriority.withOpacity(0.3)
                                : kBorderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Status Icon
                              Icon(
                                task.isCompleted
                                    ? Icons.check_circle
                                    : (isMissed
                                        ? Icons.warning_amber_rounded
                                        : Icons.radio_button_unchecked),
                                color: task.isCompleted
                                    ? kMilitaryGreen
                                    : (isMissed ? kStatusPriority : kTextDisabled),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              
                              // Task Title
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? kTextDisabled
                                        : (isMissed ? kStatusPriority : kTextPrimary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isMissed
                                      ? kStatusPriority
                                      : (task.isCompleted
                                          ? kMilitaryGreen
                                          : kStatusWarning),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isMissed
                                      ? 'OVERDUE'
                                      : (task.isCompleted ? 'DONE' : 'ACTIVE'),
                                  style: AppTextStyles.statusBadge.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: tasks.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text("Error: $err"))),
          ),
          const SliverToBoxAdapter(child: Divider(height: 32, indent: 16, endIndent: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: AppGradients.goldAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "MISSION LOGS",
                        style: AppTextStyles.sectionHeader,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          sessionsAsyncValue.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: AppGradients.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderSubtle),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: kTextDisabled,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No missions logged today",
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Start a session to begin tracking",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = sessions[index];
                    return Dismissible(
                      key: ValueKey(session.id),
                      background: Container(color: Colors.blue.shade600, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.edit_note, color: Colors.white)),
                      secondaryBackground: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete_forever, color: Colors.white)),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Confirm Deletion'), content: const Text('Are you sure you want to delete this session log?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete'))]));
                        } else {
                          await _showEditSessionDialog(context, ref, session);
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart && user != null && session.id != null) {
                          ref.read(firestoreServiceProvider).deleteStudySession(user.uid, session.id!);
                        }
                      },
                      child: SessionLogTile(session: session),
                    );
},
                  childCount: sessions.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text("Error: $err"))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEditSessionDialog(BuildContext context, WidgetRef ref, StudySession session) async {
    final subjectController = TextEditingController(text: session.subject);
    final notesController = TextEditingController(text: session.notes);
    final user = ref.read(authStateChangeProvider).value;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Study Mission'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()), maxLines: 4),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (user != null && session.id != null) {
                  ref.read(firestoreServiceProvider).updateStudySession(
                    user.uid,
                    session.id!,
                    subject: subjectController.text.trim(),
                    notes: notesController.text.trim(),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    final taskController = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Add New Mission', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 20), TextField(controller: taskController, autofocus: true, decoration: const InputDecoration(hintText: 'Enter task title...')), const SizedBox(height: 20), ElevatedButton(onPressed: () { final user = ref.read(authStateChangeProvider).value; if (taskController.text.isNotEmpty && user != null) { final newTask = Task(title: taskController.text, createdAt: Timestamp.now()); ref.read(firestoreServiceProvider).addTask(user.uid, newTask); Navigator.pop(context); } }, child: const Text('ADD')), const SizedBox(height: 20)])));
  }
}

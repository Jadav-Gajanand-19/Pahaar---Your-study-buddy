import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/task_model.dart';
import 'package:prahar/data/models/weekly_goal_model.dart';
import 'package:prahar/features/planning/screens/manage_weekly_goals_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class WeeklyOperationsScreen extends ConsumerWidget {
  const WeeklyOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Data Fetching
    final goalsAsync = ref.watch(weeklyGoalsProvider);
    final sessionsAsync = ref.watch(sessionsForStatsProvider); // Defaults to week
    final tasksAsync = ref.watch(tasksStreamProvider); // Pending tasks mainly
    final tasksForLogAsync = ref.watch(tasksForStatsProvider); // All tasks for the period

    // Helper to format duration
    String formatDuration(int totalSeconds) {
       final hours = totalSeconds / 3600;
       return '${hours.toStringAsFixed(1)} HRS';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDarkPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageWeeklyGoalsScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'EDIT OPS',
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kTextDarkPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Area
              goalsAsync.when(
                data: (goals) {
                   final total = goals.length;
                   final completed = goals.where((g) => g.isCompleted).length;
                   final progress = total > 0 ? completed / total : 0.0;
                   final percent = (progress * 100).toInt();
                   
                   final now = DateTime.now();
                   // Calculate week range for display
                   final daysToSubtract = now.weekday - 1;
                   final startOfWeek = now.subtract(Duration(days: daysToSubtract));
                   final endOfWeek = startOfWeek.add(const Duration(days: 6));
                   final weekStr = 'WEEK ${((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil()}: ${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}';

                   return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEEKLY\nOPERATIONS',
                            style: GoogleFonts.oswald(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: kTextDarkPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weekStr.toUpperCase(),
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kOlivePrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      // Circular Progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: kOlivePrimary,
                              strokeWidth: 5,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kTextDarkPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text('Error loading goals'),
              ),
              
              const SizedBox(height: 32),

              // 2. Stats Cards
              Row(
                children: [
                  // Secured Card (Dynamic)
                  Expanded(
                    child: goalsAsync.when(
                      data: (goals) {
                        final total = goals.length;
                        final completed = goals.where((g) => g.isCompleted).length;
                        return Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E4033), // Dark Olive
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'SECURED',
                                    style: GoogleFonts.oswald(fontSize: 10, color: Colors.white70, letterSpacing: 1.0),
                                  ),
                                  const Icon(Icons.track_changes, color: Colors.white24, size: 20),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '$completed',
                                  style: GoogleFonts.oswald(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                  children: [
                                    TextSpan(text: ' / $total', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? completed / total : 0,
                                  backgroundColor: Colors.white10,
                                  color: Colors.white,
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => Container(height: 120, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16))),
                      error: (_,__) => const SizedBox(),
                    )
                  ),
                  const SizedBox(width: 16),
                  
                  // Focus Time Card (Dynamic)
                  Expanded(
                    child: sessionsAsync.when(
                      data: (sessions) {
                        final totalSeconds = sessions.fold<int>(0, (sum, s) => sum + s.durationInSeconds);
                        return Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[100]!),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'FOCUS TIME',
                                    style: GoogleFonts.oswald(fontSize: 10, color: kTextDarkSecondary, letterSpacing: 1.0),
                                  ),
                                  Icon(Icons.watch_later_outlined, color: Colors.grey[300], size: 20),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  text: (totalSeconds / 3600).toStringAsFixed(0),
                                  style: GoogleFonts.oswald(fontSize: 32, fontWeight: FontWeight.bold, color: kTextDarkPrimary),
                                  children: [
                                    TextSpan(text: ' HRS', style: GoogleFonts.oswald(fontSize: 12, color: kTextDarkSecondary)),
                                  ],
                                ),
                              ),
                              Text(
                                '↗ Active Duty', // Placeholder for comparison
                                style: GoogleFonts.lato(fontSize: 10, color: kOlivePrimary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => Container(height: 120, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16))),
                      error: (_,__) => const SizedBox(),
                    )
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. High Priority Section (Dynamic - Picks first pending task)
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) return const SizedBox.shrink();
                  // Just take the first one as "High Priority" for now
                  final urgentTask = tasks.first;
                   return Column(
                     children: [
                       Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HIGH PRIORITY',
                            style: GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kOlivePrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Priority Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(width: 4, color: const Color(0xFFD32F2F)), // Red strip
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                urgentTask.title,
                                                style: GoogleFonts.oswald(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDarkPrimary),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                                              child: Text('URGENT', style: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Immediate attention required. Execute directive.',
                                          style: GoogleFonts.lato(fontSize: 14, color: kTextDarkSecondary),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: kLightBackground, borderRadius: BorderRadius.circular(20)),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.calendar_today, size: 14, color: kTextDarkSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(DateFormat('MMM dd').format(urgentTask.createdAt.toDate()), style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDarkPrimary)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text('Active', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFD32F2F))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                       const SizedBox(height: 32),
                     ],
                   );
                },
                loading: () => const SizedBox(),
                error: (_,__) => const SizedBox(),
              ),

              // 4. Mission Log Section
              Text(
                'MISSION LOG',
                style: GoogleFonts.oswald(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kTextDarkSecondary.withOpacity(0.6),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              
              // Log List (Dynamic - Uses Weekly Goals)
              goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                     return const Center(child: Text('No missions logged this week.'));
                  }
                  // Sort by creation date descending
                  final sortedGoals = List<WeeklyGoal>.from(goals)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return Column(
                    children: sortedGoals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLogItem(
                        title: goal.title,
                        subtitle: goal.category, // Show category as subtitle
                        status: goal.isCompleted ? 'SECURED' : 'ACTIVE',
                        type: goal.isCompleted ? 'done' : 'pending',
                        dotColor: goal.isCompleted ? null : kOlivePrimary,
                      ),
                    )).toList(),
                  );
                },
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e,__) => Text('Error: $e'),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
         height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2E4033),
          borderRadius: BorderRadius.circular(16),
           boxShadow: [BoxShadow(color: const Color(0xFF2E4033).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddWeeklyGoalDialog(context, ref),
          backgroundColor: Colors.transparent, 
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  void _showAddWeeklyGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedCategory = 'Educational';
    GoalType selectedGoalType = GoalType.single;
    final categories = ['Physical', 'Mental', 'Spiritual', 'Educational'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7F5), // Light grey/white background
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              
              // Icon
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey[200]!),
                 ),
                 child: const Icon(Icons.flag, color: kMilitaryGreen, size: 28),
              ),
              const SizedBox(height: 16),
              
              Text('Add Weekly Goal', style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold, color: kTextDarkPrimary)),
              const SizedBox(height: 16),
              
              // Divider "MISSION PARAMETERS"
              Row(
                children: [
                   Expanded(child: Divider(color: Colors.grey[300])),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                     child: Text('MISSION PARAMETERS', style: GoogleFonts.oswald(fontSize: 10, letterSpacing: 2.0, color: kTextDarkSecondary)),
                   ),
                   Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),
              
              // Goal Title Logic
              Align(alignment: Alignment.centerLeft, child: Text('GOAL TITLE', style: GoogleFonts.oswald(fontSize: 10, letterSpacing: 1.5, color: kTextDarkSecondary))),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'e.g. Complete Geography Chapter 4',
                  hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                ),
              ),
              const SizedBox(height: 20),

              // Category Logic
              Align(alignment: Alignment.centerLeft, child: Text('CATEGORY', style: GoogleFonts.oswald(fontSize: 10, letterSpacing: 1.5, color: kTextDarkSecondary))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: Icon(Icons.expand_more, color: Colors.grey[600]),
                    items: categories.map((c) => DropdownMenuItem(
                      value: c, 
                      child: Row(
                        children: [
                          Icon(Icons.donut_large, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(c, style: GoogleFonts.lato(color: kTextDarkPrimary)),
                        ],
                      )
                    )).toList(),
                    onChanged: (v) { if(v!=null) setState(()=>selectedCategory=v); },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              
              // Goal Type Selection
              Align(alignment: Alignment.centerLeft, child: Text('GOAL TYPE', style: GoogleFonts.oswald(fontSize: 10, letterSpacing: 1.5, color: kTextDarkSecondary))),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    RadioListTile<GoalType>(
                      value: GoalType.single,
                      groupValue: selectedGoalType,
                      onChanged: (v) { if(v!=null) setState(()=>selectedGoalType=v); },
                      title: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20, color: kMilitaryGreen),
                          const SizedBox(width: 8),
                          Text('Single Task', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: kTextDarkPrimary)),
                        ],
                      ),
                      subtitle: Text('Complete once this week', style: GoogleFonts.lato(fontSize: 12, color: kTextDarkSecondary)),
                      activeColor: kMilitaryGreen,
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    RadioListTile<GoalType>(
                      value: GoalType.daily,
                      groupValue: selectedGoalType,
                      onChanged: (v) { if(v!=null) setState(()=>selectedGoalType=v); },
                      title: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: kMilitaryGreen),
                          const SizedBox(width: 8),
                          Text('Daily Task', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: kTextDarkPrimary)),
                        ],
                      ),
                      subtitle: Text('Complete each day of the week', style: GoogleFonts.lato(fontSize: 12, color: kTextDarkSecondary)),
                      activeColor: kMilitaryGreen,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ENCRYPTION', style: GoogleFonts.oswald(fontSize: 8, color: kTextDarkSecondary)),
                      Text('AES-256', style: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold, color: kTextDarkSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('SYSTEM STATUS', style: GoogleFonts.oswald(fontSize: 8, color: kTextDarkSecondary)),
                      const SizedBox(width: 4),
                      Row(children: List.generate(3, (i) => Container(margin: const EdgeInsets.only(left: 2), width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: kTextDarkSecondary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                       onPressed: () {
                         if (titleController.text.isNotEmpty) {
                            final user = ref.read(authStateChangeProvider).value;
                            if (user != null) {
                               final firestoreService = ref.read(firestoreServiceProvider);
                               
                               // Initialize daily completions for daily goals
                               final dailyCompletions = selectedGoalType == GoalType.daily
                                   ? {0: false, 1: false, 2: false, 3: false, 4: false, 5: false, 6: false}
                                   : <int, bool>{};
                               
                               final newGoal = WeeklyGoal(
                                 title: titleController.text.trim(),
                                 category: selectedCategory,
                                 goalType: selectedGoalType,
                                 dailyCompletions: dailyCompletions,
                                 weekId: firestoreService.getWeekId(DateTime.now()),
                                 createdAt: Timestamp.now(),
                               );
                               firestoreService.addWeeklyGoal(user.uid, newGoal);
                            }
                            Navigator.pop(context);
                         }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: kMilitaryGreen, // Dark Green
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text('Add Goal', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
                           const SizedBox(width: 8),
                           const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem({required String title, required String subtitle, String? status, required String type, Color? dotColor}) {
    final isDone = type == 'done';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? kLightBackground.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: isDone ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset:const Offset(0, 2))],
      ),
      child: Row(
        children: [
          if (isDone)
            const Icon(Icons.check_circle_outline, color: kMilitaryGreen, size: 24)
          else 
            Container(
              height: 24, width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
            ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone ? kTextDarkSecondary.withOpacity(0.5) : kTextDarkPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (dotColor != null && !isDone) ...[
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        subtitle,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: kTextDarkSecondary,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          
          if (status != null)
            if (isDone)
              Row(
                children: [
                   const Icon(Icons.check, size: 14, color: kMilitaryGreen),
                   const SizedBox(width: 4),
                   Text('DONE', style: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold, color: kMilitaryGreen, letterSpacing: 1.0)),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.oswald(fontSize: 10, fontWeight: FontWeight.bold, color: kTextDarkSecondary, letterSpacing: 1.0),
                ),
              ),
        ],
      ),
    );
  }
}

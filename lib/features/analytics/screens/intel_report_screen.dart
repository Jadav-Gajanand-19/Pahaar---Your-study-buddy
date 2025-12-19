import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/providers/firestore_providers.dart';
import 'package:prahar/providers/analytics_providers.dart';
import 'package:prahar/data/models/task_model.dart';
import 'dart:math';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/data/models/study_session_model.dart';
import 'package:prahar/features/fitness/models/workout_model.dart';
import 'package:prahar/providers/auth_providers.dart';

class IntelReportScreen extends ConsumerWidget {
  const IntelReportScreen({super.key});

  String _formatDuration(double totalHours) {
    if (totalHours == 0) return '00:00';
    final int hours = totalHours.floor();
    final int minutes = ((totalHours - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statsDateRangeProvider);
    final rangeNotifier = ref.read(statsDateRangeProvider.notifier);
    final sessionsAsync = ref.watch(sessionsForStatsProvider);
    final tasksAsync = ref.watch(tasksForStatsProvider);
    final habitsAsync = ref.watch(habitLogsForStatsProvider);
    final user = ref.watch(authStateChangeProvider).value;
    
    // Get workouts for the selected date range
    final now = DateTime.now();
    final (start, end) = range == StatsDateRange.week
        ? _getWeekDateRange()
        : (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1));
    
    final workoutsAsync = user != null
        ? ref.watch(workoutsForDateRangeProvider((userId: user.uid, start: start, end: end)))
        : const AsyncValue.data([]);

    // Data Calculation
    final double totalHours = sessionsAsync.maybeWhen(
      data: (sessions) => sessions.fold(0.0, (prev, session) => prev + session.durationInSeconds) / 3600.0,
      orElse: () => 0.0,
    );
    
    final int tasksCompleted = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => t.isCompleted).length,
      orElse: () => 0,
    );
     final int tasksPending = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => !t.isCompleted).length,
      orElse: () => 0,
    );
    final int totalTasks = tasksCompleted + tasksPending;
    final int efficiency = totalTasks > 0 ? ((tasksCompleted / totalTasks) * 100).round() : 0;
    
    final numDaysStudied = sessionsAsync.maybeWhen(
      data: (sessions) => sessions.map((s) => DateFormat('yyyy-MM-dd').format(s.startTime)).toSet().length,
      orElse: () => 1,
    );
    final double avgHours = (range == StatsDateRange.week)
        ? (totalHours / 7)
        : (numDaysStudied > 0 ? totalHours / numDaysStudied : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5), // Light Grey bg
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INTEL REPORT',
              style: GoogleFonts.blackOpsOne(
                color: const Color(0xFF1E232C),
                fontSize: 24,
                letterSpacing: 1.0,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'STATUS: ACTIVE DUTY',
                  style: GoogleFonts.blackOpsOne(
                    color: Colors.grey[600],
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), // Light grey circle
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.bar_chart, color: Color(0xFF1E232C)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            _buildMonthSelector(ref),
            const SizedBox(height: 16),
            
            // Segment Switcher
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  _buildSegment(context, 'This Week', range == StatsDateRange.week, () => rangeNotifier.state = StatsDateRange.week),
                  _buildSegment(context, 'This Month', range == StatsDateRange.month, () => rangeNotifier.state = StatsDateRange.month),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF33691E), size: 18),
                const SizedBox(width: 8),
                Text(
                  "COMMANDANT'S OVERVIEW",
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey[600], 
                    letterSpacing: 1.5
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: 'TOTAL STUDY\nHOURS',
                    value: _formatDuration(totalHours),
                    subtitle: '+12% vs last week',
                    isPositive: true,
                    icon: Icons.timer,
                    subtitleFontSize: 10, // Reduced from default 12
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    title: 'DAILY AVERAGE',
                    value: _formatDuration(avgHours),
                    subtitle: 'On Track',
                    isPositive: true,
                    icon: Icons.timelapse,
                    showDot: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // New Stats Row: Discipline & Consistency
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: 'DISCIPLINE',
                    value: habitsAsync.maybeWhen(
                      data: (logs) {
                        if (logs.isEmpty) return '0%';
                        final completed = logs.where((log) => (log.data() as Map)['isCompleted'] == true).length;
                        final rate = (completed / logs.length * 100).round();
                        return '$rate%';
                      },
                      orElse: () => '0%',
                    ),
                    subtitle: 'Habit Completion',
                    isPositive: true,
                    icon: Icons.military_tech,
                    showDot: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    title: 'CONSISTENCY',
                    value: '${_calculateWorkoutStreak(workoutsAsync)}',
                    subtitle: 'Day Streak',
                    isPositive: true,
                    icon: Icons.local_fire_department,
                    showDot: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Task Completion Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.task_alt, color: Color(0xFF33691E)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'TASK COMPLETION',
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E232C),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTaskStat('Completed', '$tasksCompleted', Colors.green),
                      _buildTaskStat('Pending', '$tasksPending', Colors.orange),
                      _buildTaskStat('Rate', '$efficiency%', const Color(0xFF33691E)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Effort Distribution Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.pie_chart, color: Color(0xFF33691E)),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'EFFORT DISTRIBUTION',
                                style: GoogleFonts.blackOpsOne(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold, 
                                  color: const Color(0xFF1E232C),
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Donut Chart
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 70,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF33691E), // Dark Green
                                value: 50,
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFAFB42B), // Olive
                                value: 25,
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFEF5350), // Red
                                value: 25,
                                radius: 25,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$efficiency%',
                              style: GoogleFonts.blackOpsOne(
                                fontSize: 40, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFF1E232C)
                              ),
                            ),
                            Text(
                              'EFFICIENCY',
                              style: GoogleFonts.blackOpsOne(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.grey[500],
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0,2))
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF81C784), shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text('Live Data', style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _buildLegendItem('COMPLETED', '50%', const Color(0xFF33691E))),
                      const SizedBox(width: 8),
                      Flexible(child: _buildLegendItem('PENDING', '25%', const Color(0xFFAFB42B))),
                      const SizedBox(width: 8),
                      Flexible(child: _buildLegendItem('MISSED', '25%', const Color(0xFFEF5350))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Week Comparison Section
            _buildWeekComparison(ref),
            const SizedBox(height: 24),
            
            // Mock Test Analytics Section
            _buildMockTestAnalytics(ref),
            const SizedBox(height: 24),
            
            // Study Time Distribution
            _buildStudyDistribution(ref, sessionsAsync),
            
            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF33691E) : Colors.transparent, // Military Green
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.lato(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String subtitle,
    required bool isPositive,
    required IconData icon,
    bool showDot = false,
    double subtitleFontSize = 12, // Added parameter with default value
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
        Positioned(
           top: 0, right: 0,
           child: Icon(icon, color: Colors.grey[200], size: 48),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.blackOpsOne(
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[500],
                letterSpacing: 0.9,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.blackOpsOne(
                fontSize: 28, // Reduced from 32
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF1E232C)
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (showDot)
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(color: Color(0xFFFDD835), shape: BoxShape.circle), // Yellow dot
                  ),
                if (!showDot)
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 14, // Reduced from 16
                    color: isPositive ? const Color(0xFF00C853) : Colors.red,
                  ),
                if (!showDot) const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: subtitleFontSize, // Use parameter
                      fontWeight: FontWeight.bold, 
                      color: showDot ? Colors.grey[600] : (isPositive ? const Color(0xFF00C853) : Colors.red),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.blackOpsOne(
               fontSize: 10, 
               fontWeight: FontWeight.bold, 
               color: Colors.grey[500]
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                percent,
                style: GoogleFonts.blackOpsOne(
                   fontSize: 14, 
                   fontWeight: FontWeight.bold, 
                   color: const Color(0xFF1E232C)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  int _calculateWorkoutStreak(AsyncValue sessionsAsync) {
    return sessionsAsync.maybeWhen(
      data: (sessions) {
        if (sessions.isEmpty) return 0;
        // Simple streak calculation based on consecutive days
        int streak = 1;
        final dates = sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().toList();
        dates.sort((a, b) => b.compareTo(a) as int);
        
        for (int i = 0; i < dates.length - 1; i++) {
          final diff = dates[i].difference(dates[i + 1]).inDays;
          if (diff == 1) {
            streak++;
          } else {
            break;
          }
        }
        return streak;
      },
      orElse: () => 0,
    );
  }
  
  Widget _buildTaskStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.blackOpsOne(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.blackOpsOne(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
  
  (DateTime, DateTime) _getWeekDateRange() {
    final now = DateTime.now();
    final daysToSubtract = now.weekday % 7;
    final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return (startOfWeek, endOfWeek);
  }
  
  Widget _buildMonthSelector(WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthNotifier = ref.read(selectedMonthProvider.notifier);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    // Check if we can navigate forward (not already at current month)
    final canGoForward = selectedMonth.isBefore(currentMonth);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
              monthNotifier.state = newMonth;
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: GoogleFonts.blackOpsOne(
              fontSize: 16,
              color: const Color(0xFF1E232C),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: canGoForward ? Colors.black : Colors.grey[300],
            ),
            onPressed: canGoForward ? () {
              final newMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
              // Only allow if not going beyond current month
              if (!newMonth.isAfter(currentMonth)) {
                monthNotifier.state = newMonth;
              }
            } : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeekComparison(WidgetRef ref) {
    final comparisonAsync = ref.watch(weekComparisonProvider);
    final bestWeekAsync = ref.watch(bestWeekProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up, color: Color(0xFF33691E)),
              ),
              const SizedBox(width: 12),
              Text(
                'WEEK PERFORMANCE',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E232C),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          comparisonAsync.when(
            data: (comparison) {
              if (comparison == null) return const Text('No data');
              
              return Column(
                children: [
                  // Current vs Previous Week
                  _buildComparisonRow('Study Hours', 
                    comparison.currentWeek.studyHours.toString(),
                    comparison.previousWeek.studyHours.toString(),
                    comparison.percentChanges['studyHours'] ?? 0,
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonRow('Workouts',
                    comparison.currentWeek.workouts.toString(),
                    comparison.previousWeek.workouts.toString(),
                    comparison.percentChanges['workouts'] ?? 0,
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonRow('Habit Streak',
                    '${comparison.currentWeek.habitStreakDays} days',
                    '${comparison.previousWeek.habitStreakDays} days',
                    comparison.percentChanges['habitStreak'] ?? 0,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Error loading comparison'),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Best Week
          bestWeekAsync.when(
            data: (bestWeek) {
              if (bestWeek == null) return const SizedBox();
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDD835)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFDD835), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEST WEEK',
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(bestWeek.weekStart),
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 16,
                              color: const Color(0xFF1E232C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${bestWeek.overallScore.toInt()}%',
                      style: GoogleFonts.blackOpsOne(
                        fontSize: 24,
                        color: const Color(0xFF33691E),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComparisonRow(String label, String current, String previous, double change) {
    final isPositive = change >= 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            Text(
              current,
              style: GoogleFonts.blackOpsOne(
                fontSize: 16,
                color: const Color(0xFF1E232C),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: isPositive ? Colors.green : Colors.red,
            ),
            Text(
              '${change.abs().toStringAsFixed(0)}%',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMockTestAnalytics(WidgetRef ref) {
    final analyticsAsync = ref.watch(mockTestAnalyticsProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, color: Color(0xFF33691E)),
              ),
              const SizedBox(width: 12),
              Text(
                'MOCK TEST ANALYTICS',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E232C),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          analyticsAsync.when(
            data: (analytics) {
              if (analytics == null || analytics.totalTests == 0) {
                return Text(
                  'No mock tests completed this period',
                  style: GoogleFonts.lato(color: Colors.grey[600]),
                );
              }
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMockTestStat('Tests', analytics.totalTests.toString()),
                      _buildMockTestStat('Avg Score', '${analytics.averageScore.toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Subject Scores
                  ...analytics.subjectScores.entries.map((entry) {
                    final subject = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                subject.subject,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${subject.averageScore.toStringAsFixed(0)}%',
                                style: GoogleFonts.blackOpsOne(
                                  fontSize: 14,
                                  color: _getScoreColor(subject.averageScore),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: subject.averageScore / 100,
                              backgroundColor: Colors.grey[200],
                              color: _getScoreColor(subject.averageScore),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMockTestStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.blackOpsOne(
            fontSize: 28,
            color: const Color(0xFF33691E),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildStudyDistribution(WidgetRef ref, AsyncValue<List<StudySession>> sessionsAsync) {
    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox();
        
        // Calculate subject distribution
        final Map<String, double> distribution = {};
        for (final session in sessions) {
          final hours = session.durationInSeconds / 3600;
          distribution[session.subject] = (distribution[session.subject] ?? 0) + hours;
        }
        
        if (distribution.isEmpty) return const SizedBox();
        
        final total = distribution.values.reduce((a, b) => a + b);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.donut_large, color: Color(0xFF33691E)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'STUDY DISTRIBUTION',
                    style: GoogleFonts.blackOpsOne(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E232C),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ...distribution.entries.map((entry) {
                final percent = (entry.value / total * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: GoogleFonts.lato(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: Colors.grey[200],
                            color: const Color(0xFF33691E),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: GoogleFonts.blackOpsOne(
                            fontSize: 12,
                            color: const Color(0xFF1E232C),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (e, _) => const SizedBox(),
    );
  }
}

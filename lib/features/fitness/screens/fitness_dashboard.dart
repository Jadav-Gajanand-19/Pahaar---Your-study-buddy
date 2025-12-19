import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/fitness/models/workout_model.dart';
import 'package:prahar/features/fitness/data/workout_plans.dart';
import 'package:prahar/features/fitness/screens/workout_logger_screen.dart';
import 'package:prahar/features/fitness/screens/workout_plan_screen.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

// Reuse GridPainter from AddEditEntryScreen or define here
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Fitness Dashboard - COMBAT READINESS CENTER
class FitnessDashboard extends ConsumerWidget {
  const FitnessDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final user = ref.watch(authStateChangeProvider).value;
    final workoutsStream = ref.watch(workoutsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(
             child: CustomPaint(
               painter: GridPainter(),
             ),
          ),
          SafeArea(
            child: workoutsStream.when(
              data: (workouts) {
                final stats = _calculateStats(workouts);
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Header
                      Text(
                        'FITNESS TRACKER',
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kCommandGold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'COMBAT READINESS',
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 32,
                          color: const Color(0xFF1E232C),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SSB Standards Card
                      _buildSSBStandardsCard(stats),
                      const SizedBox(height: 24),

                      // Quick Stats (Streak & Missions)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatSquare(
                              icon: Icons.local_fire_department,
                              value: '${stats['streak']}',
                              label: 'DAY STREAK',
                              iconColor: const Color(0xFFFF6F00), // Fire Orange
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatSquare(
                              icon: Icons.fitness_center,
                              value: '${stats['totalWorkouts']}',
                              label: 'MISSIONS',
                              iconColor: kMilitaryGreen, 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recommended Program Section
                      Text(
                        'RECOMMENDED PROGRAM',
                         style: GoogleFonts.blackOpsOne(
                          fontSize: 20,
                          color: const Color(0xFF1E232C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendedProgramCard(context, stats),
                      
                      const SizedBox(height: 32),
                      
                      // Recent Missions Log (Restored Feature)
                      _buildRecentMissionsLog(workouts, ref),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: kCommandGold)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  // ... (stats calculation logic remains same)
  // Calculate statistics (kept same logic)
  Map<String, dynamic> _calculateStats(List<WorkoutModel> workouts) {
    final stats = {
      'totalWorkouts': workouts.length,
      'runningPB': 0.0,
      'pushupsPB': 0,
      'situpsPB': 0,
      'pullupsPB': 0,
      'streak': 0,
    };

    for (var workout in workouts) {
      switch (workout.type) {
        case WorkoutType.running:
          if (workout.value > (stats['runningPB'] as double)) stats['runningPB'] = workout.value;
          break;
        case WorkoutType.pushups:
          if (workout.value > (stats['pushupsPB'] as int)) stats['pushupsPB'] = workout.value.toInt();
          break;
        case WorkoutType.situps:
          if (workout.value > (stats['situpsPB'] as int)) stats['situpsPB'] = workout.value.toInt();
          break;
        case WorkoutType.pullups:
          if (workout.value > (stats['pullupsPB'] as int)) stats['pullupsPB'] = workout.value.toInt();
          break;
      }
    }

    if (workouts.isNotEmpty) {
      int streak = 1;
      for (int i = 0; i < workouts.length - 1; i++) {
        final diff = workouts[i].date.difference(workouts[i + 1].date).inDays;
        if (diff == 1) streak++; else break;
      }
      stats['streak'] = streak;
    }

    return stats;
  }

  // ... (other widgets remain same)

  Widget _buildRecentMissionsLog(List<WorkoutModel> workouts, WidgetRef ref) {
    if (workouts.isEmpty) return const SizedBox.shrink();

     // Group workouts by date
    final groupedWorkouts = <String, List<WorkoutModel>>{};
    for (var workout in workouts) {
      final dateKey = _formatDate(workout.date);
      if (!groupedWorkouts.containsKey(dateKey)) {
        groupedWorkouts[dateKey] = [];
      }
      groupedWorkouts[dateKey]!.add(workout);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MISSION LOG',
          style: GoogleFonts.blackOpsOne(
            fontSize: 20,
            color: const Color(0xFF1E232C),
          ),
        ),
        const SizedBox(height: 16),
        ...groupedWorkouts.entries.map((entry) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 8.0),
                 child: Text(
                   entry.key.toUpperCase(),
                   style: GoogleFonts.blackOpsOne(
                     fontSize: 12,
                     fontWeight: FontWeight.bold,
                     color: Colors.grey[500],
                     letterSpacing: 1.0,
                   ),
                 ),
               ),
                ...entry.value.map((workout) => Dismissible(
                  key: ValueKey(workout.id!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) {
                    final user = ref.read(authStateChangeProvider).value;
                    if (user != null && workout.id != null) {
                      ref.read(firestoreServiceProvider).deleteWorkout(user.uid, workout.id!);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.03),
                           blurRadius: 8,
                           offset: const Offset(0, 2),
                         ),
                       ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1), // Light Amber
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getWorkoutIcon(workout.type),
                            color: kCommandGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            workout.getMilitaryName(),
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E232C),
                            ),
                          ),
                        ),
                        Text(
                          workout.getFormattedValue(),
                          style: GoogleFonts.blackOpsOne(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kCommandGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
             ],
           );
        }),
      ],
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.pushups:
        return Icons.accessibility_new;
      case WorkoutType.situps:
        return Icons.airline_seat_flat;
      case WorkoutType.pullups:
        return Icons.fitness_center;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSSBStandardsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SSB STANDARDS PROGRESS',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kCommandGold, // Using App Color
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(Icons.open_in_full, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressRow('Endurance Run', stats['runningPB'], SSBStandard.runningTarget, 'km'),
          const SizedBox(height: 20),
          _buildProgressRow('Push-ups', stats['pushupsPB'].toDouble(), SSBStandard.pushupsTarget.toDouble(), 'reps'),
          const SizedBox(height: 20),
          _buildProgressRow('Sit-ups', stats['situpsPB'].toDouble(), SSBStandard.situpsTarget.toDouble(), 'reps'),
          const SizedBox(height: 20),
          _buildProgressRow('Pull-ups', stats['pullupsPB'].toDouble(), SSBStandard.pullupsTarget.toDouble(), 'reps'),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String title, double current, double target, String unit) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E232C),
              ),
            ),
            Row(
              children: [
                Text(
                  '${current.toStringAsFixed(current < 10 && unit == "km" ? 1 : 0)}/${target.toStringAsFixed(0)} $unit',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kCommandGold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: kCommandGold,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatSquare({required IconData icon, required String value, required String label, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.blackOpsOne(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E232C),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.blackOpsOne(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProgramCard(BuildContext context, Map<String, dynamic> stats) {
    // Logic to recommend program
    final recommendedPlan = WorkoutPlans.recommendPlan(
      runningKm: stats['runningPB'],
      pushups: stats['pushupsPB'],
      situps: stats['situpsPB'],
      pullups: stats['pullupsPB'],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  recommendedPlan.name.toUpperCase(),
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kCommandGold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Removed level badge to prevent overflow
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendedPlan.description, // "Build foundational fitness..."
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Flexible(
                child: Text(
                  '${recommendedPlan.weeks} WEEKS',
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 0.7,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkoutLoggerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text('LOG MISSION', style: GoogleFonts.blackOpsOne(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCommandGold,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

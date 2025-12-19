import 'package:prahar/data/datasources/firestore_service.dart';
import 'package:prahar/features/fitness/data/workout_plans.dart';

/// Workout Plan Generator Service
/// Creates personalized workout plans based on fitness level and SSB standards
class WorkoutPlanGeneratorService {
  final FirestoreService _firestoreService;

  WorkoutPlanGeneratorService(this._firestoreService);

  /// Generate a workout plan based on current fitness level
  Future<WorkoutPlan> generatePlan(String userId) async {
    try {
      // Assess current fitness level
      final currentStats = await _assessCurrentFitness(userId);
      
      // Calculate SSB gaps
      final gaps = _calculateSSBGaps(currentStats);
      
      // Generate plan
      return _createPlan(currentStats, gaps);
    } catch (e) {
      print('Error generating workout plan: $e');
      return _getDefaultPlan();
    }
  }

  Future<Map<String, double>> _assessCurrentFitness(String userId) async {
    // TODO: Fetch recent workout data
    return {
      'running': 0.0,
      'pushups': 0.0,
      'situps': 0.0,
      'pullups': 0.0,
    };
  }

  Map<String, double> _calculateSSBGaps(Map<String, double> current) {
    return {
      'running': SSBStandard.runningTarget - current['running']!,
      'pushups': SSBStandard.pushupsTarget - current['pushups']!,
      'situps': SSBStandard.situpsTarget - current['situps']!,
      'pullups': SSBStandard.pullupsTarget - current['pullups']!,
    };
  }

  WorkoutPlan _createPlan(Map<String, double> current, Map<String, double> gaps) {
    // Determine intensity based on gaps
    final avgGap = gaps.values.reduce((a, b) => a + b) / gaps.length;
    
    if (avgGap > 50) {
      return WorkoutPlan(
        name: 'Foundation Builder',
        level: 'Beginner',
        weeks: 8,
        description: 'Build basic fitness foundation',
        weeklySchedule: _generateBeginnerSchedule(),
      );
    } else if (avgGap > 20) {
      return WorkoutPlan(
        name: 'SSB Preparation',
        level: 'Intermediate',
        weeks: 6,
        description: 'Bridge to SSB standards',
        weeklySchedule: _generateIntermediateSchedule(),
      );
    } else {
      return WorkoutPlan(
        name: 'Peak Performance',
        level: 'Advanced',
        weeks: 4,
        description: 'Maintain and exceed SSB standards',
        weeklySchedule: _generateAdvancedSchedule(),
      );
    }
  }

  Map<String, String> _generateBeginnerSchedule() {
    return {
      'Monday': 'Running 2km + Push-ups 3x10',
      'Wednesday': 'Sit-ups 3x15 + Pull-ups 3x3',
      'Friday': 'Running 2.5km + Full body',
    };
  }

  Map<String, String> _generateIntermediateSchedule() {
    return {
      'Monday': 'Running 3km + Push-ups 3x15',
      'Wednesday': 'Sit-ups 3x20 + Pull-ups 3x5',
      'Friday': 'Running 4km',
      'Saturday': 'Strength circuit',
    };
  }

  Map<String, String> _generateAdvancedSchedule() {
    return {
      'Monday': 'Running 5km + Push-ups 3x20',
      'Tuesday': 'Sit-ups 3x30 + Pull-ups 3x8',
      'Thursday': 'Running 6km',
      'Saturday': 'SSB simulation drill',
    };
  }

  WorkoutPlan _getDefaultPlan() {
    return WorkoutPlan(
      name: 'SSB Starter',
      level: 'Beginner',
      weeks: 8,
      description: 'Start your SSB fitness journey',
      weeklySchedule: _generateBeginnerSchedule(),
    );
  }
}

/// Workout Plan Model
class WorkoutPlan {
  final String name;
  final String level;
  final int weeks;
  final String description;
  final Map<String, String> weeklySchedule;

  WorkoutPlan({
    required this.name,
    required this.level,
    required this.weeks,
    required this.description,
    required this.weeklySchedule,
  });
}

/// SSB Standards (from existing workout_plans.dart data)
class SSBStandard {
  static const double runningTarget = 5.0; // km
  static const int pushupsTarget = 40;
  static const int situpsTarget = 50;
  static const int pullupsTarget = 8;
}

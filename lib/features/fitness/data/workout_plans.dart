import 'package:prahar/features/fitness/models/workout_model.dart';

/// Pre-defined SSB workout plans for different skill levels
class WorkoutPlans {
  // Beginner Plan - 8 weeks
  static final WorkoutPlanModel beginner = WorkoutPlanModel(
    id: 'beginner',
    name: 'RECRUIT CONDITIONING',
    level: PlanLevel.beginner,
    weeks: 8,
    description: 'Build foundational fitness for SSB standards',
    weeklyTargets: [
      WeeklyTarget(week: 1, runningKm: 2.0, pushups: 10, situps: 15, pullups: 2),
      WeeklyTarget(week: 2, runningKm: 2.5, pushups: 12, situps: 18, pullups: 3),
      WeeklyTarget(week: 3, runningKm: 3.0, pushups: 15, situps: 20, pullups: 4),
      WeeklyTarget(week: 4, runningKm: 3.5, pushups: 18, situps: 25, pullups: 5),
      WeeklyTarget(week: 5, runningKm: 4.0, pushups: 20, situps: 28, pullups: 6),
      WeeklyTarget(week: 6, runningKm: 4.5, pushups: 23, situps: 32, pullups: 7),
      WeeklyTarget(week: 7, runningKm: 5.0, pushups: 25, situps: 35, pullups: 8),
      WeeklyTarget(week: 8, runningKm: 5.0, pushups: 30, situps: 40, pullups: 8),
    ],
  );

  // Intermediate Plan - 8 weeks
  static final WorkoutPlanModel intermediate = WorkoutPlanModel(
    id: 'intermediate',
    name: 'TACTICAL ADVANCEMENT',
    level: PlanLevel.intermediate,
    weeks: 8,
    description: 'Progress towards SSB readiness',
    weeklyTargets: [
      WeeklyTarget(week: 1, runningKm: 5.0, pushups: 30, situps: 40, pullups: 8),
      WeeklyTarget(week: 2, runningKm: 5.5, pushups: 32, situps: 42, pullups: 9),
      WeeklyTarget(week: 3, runningKm: 6.0, pushups: 35, situps: 45, pullups: 10),
      WeeklyTarget(week: 4, runningKm: 6.5, pushups: 37, situps: 48, pullups: 11),
      WeeklyTarget(week: 5, runningKm: 7.0, pushups: 40, situps: 50, pullups: 12),
      WeeklyTarget(week: 6, runningKm: 8.0, pushups: 42, situps: 52, pullups: 13),
      WeeklyTarget(week: 7, runningKm: 9.0, pushups: 45, situps: 55, pullups: 14),
      WeeklyTarget(week: 8, runningKm: 10.0, pushups: 50, situps: 60, pullups: 15),
    ],
  );

  // Advanced Plan - 8 weeks (Maintain SSB Standard+)
  static final WorkoutPlanModel advanced = WorkoutPlanModel(
    id: 'advanced',
    name: 'ELITE OPERATIONS',
    level: PlanLevel.advanced,
    weeks: 8,
    description: 'Exceed SSB standards, maintain peak fitness',
    weeklyTargets: [
      WeeklyTarget(week: 1, runningKm: 10.0, pushups: 50, situps: 60, pullups: 15),
      WeeklyTarget(week: 2, runningKm: 11.0, pushups: 52, situps: 62, pullups: 16),
      WeeklyTarget(week: 3, runningKm: 12.0, pushups: 55, situps: 65, pullups: 17),
      WeeklyTarget(week: 4, runningKm: 12.0, pushups: 57, situps: 67, pullups: 18),
      WeeklyTarget(week: 5, runningKm: 13.0, pushups: 60, situps: 70, pullups: 18),
      WeeklyTarget(week: 6, runningKm: 13.0, pushups: 62, situps: 72, pullups: 19),
      WeeklyTarget(week: 7, runningKm: 14.0, pushups: 65, situps: 75, pullups: 20),
      WeeklyTarget(week: 8, runningKm: 15.0, pushups: 70, situps: 80, pullups: 20),
    ],
  );

  // Get all plans
  static List<WorkoutPlanModel> getAllPlans() {
    return [beginner, intermediate, advanced];
  }

  // Get plan by level
  static WorkoutPlanModel getPlanByLevel(PlanLevel level) {
    switch (level) {
      case PlanLevel.beginner:
        return beginner;
      case PlanLevel.intermediate:
        return intermediate;
      case PlanLevel.advanced:
        return advanced;
    }
  }

  // Recommend plan based on current performance
  static WorkoutPlanModel recommendPlan({
    double? runningKm,
    int? pushups,
    int? situps,
    int? pullups,
  }) {
    // Calculate average performance percentage
    double meetsCount = 0;
    int totalChecked = 0;

    if (runningKm != null) {
      totalChecked++;
      if (runningKm >= SSBStandard.runningTarget) meetsCount++;
      else if (runningKm >= 5.0) meetsCount += 0.5;
    }

    if (pushups != null) {
      totalChecked++;
      if (pushups >= SSBStandard.pushupsTarget) meetsCount++;
      else if (pushups >= 25) meetsCount += 0.5;
    }

    if (situps != null) {
      totalChecked++;
      if (situps >= SSBStandard.situpsTarget) meetsCount++;
      else if (situps >= 35) meetsCount += 0.5;
    }

    if (pullups != null) {
      totalChecked++;
      if (pullups >= SSBStandard.pullupsTarget) meetsCount++;
      else if (pullups >= 8) meetsCount += 0.5;
    }

    if (totalChecked == 0) return beginner;

    final performanceRatio = meetsCount / totalChecked;

    if (performanceRatio >= 1.0) {
      return advanced; // Exceeds all standards
    } else if (performanceRatio >= 0.5) {
      return intermediate; // Meets some standards
    } else {
      return beginner; // Below most standards
    }
  }
}

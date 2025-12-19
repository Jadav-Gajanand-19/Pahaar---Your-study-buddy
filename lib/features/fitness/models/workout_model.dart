import 'package:cloud_firestore/cloud_firestore.dart';

/// Workout Model - Represents a single training mission
/// Supports: Running, Push-ups, Sit-ups, Pull-ups
class WorkoutModel {
  final String? id;
  final String userId;
  final WorkoutType type;
  final double value; // distance in km for running, reps for exercises
  final int durationMinutes; // time spent on workout
  final DateTime date;
  final String? notes;
  final Timestamp createdAt;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.durationMinutes,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  // Convert from Firestore
  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: WorkoutType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => WorkoutType.running,
      ),
      value: (data['value'] ?? 0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString(),
      'value': value,
      'durationMinutes': durationMinutes,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  // Get formatted value based on type
  String getFormattedValue() {
    switch (type) {
      case WorkoutType.running:
        return '${value.toStringAsFixed(2)} km';
      case WorkoutType.pushups:
      case WorkoutType.situps:
      case WorkoutType.pullups:
        return '${value.toInt()} reps';
    }
  }

  // Get display name
  String getDisplayName() {
    switch (type) {
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.pushups:
        return 'Push-ups';
      case WorkoutType.situps:
        return 'Sit-ups';
      case WorkoutType.pullups:
        return 'Pull-ups';
    }
  }

  // Get military term
  String getMilitaryName() {
    switch (type) {
      case WorkoutType.running:
        return 'ENDURANCE RUN';
      case WorkoutType.pushups:
        return 'UPPER BODY DRILL';
      case WorkoutType.situps:
        return 'CORE CONDITIONING';
      case WorkoutType.pullups:
        return 'STRENGTH ASSESSMENT';
    }
  }
}

/// Workout Types
enum WorkoutType {
  running,
  pushups,
  situps,
  pullups,
}

/// Workout Plan Model - Pre-defined SSB training programs
class WorkoutPlanModel {
  final String id;
  final String name;
  final PlanLevel level;
  final int weeks;
  final List<WeeklyTarget> weeklyTargets;
  final String description;

  WorkoutPlanModel({
    required this.id,
    required this.name,
    required this.level,
    required this.weeks,
    required this.weeklyTargets,
    required this.description,
  });
}

/// Plan difficulty levels
enum PlanLevel {
  beginner,
  intermediate,
  advanced,
}

/// Weekly targets for each workout type
class WeeklyTarget {
  final int week;
  final double? runningKm;
  final int? pushups;
  final int? situps;
  final int? pullups;

  WeeklyTarget({
    required this.week,
    this.runningKm,
    this.pushups,
    this.situps,
    this.pullups,
  });
}

/// SSB Standard Benchmarks
class SSBStandard {
  static const double runningTarget = 10.0; // 10 km in <50 mins
  static const int pushupsTarget = 50; // Continuous
  static const int situpsTarget = 60; // In 2 minutes
  static const int pullupsTarget = 15; // Continuous

  // Check if user meets SSB standard
  static bool meetsStandard(WorkoutType type, double value) {
    switch (type) {
      case WorkoutType.running:
        return value >= runningTarget;
      case WorkoutType.pushups:
        return value >= pushupsTarget;
      case WorkoutType.situps:
        return value >= situpsTarget;
      case WorkoutType.pullups:
        return value >= pullupsTarget;
    }
  }

  // Get target for workout type
  static double getTarget(WorkoutType type) {
    switch (type) {
      case WorkoutType.running:
        return runningTarget;
      case WorkoutType.pushups:
        return pushupsTarget.toDouble();
      case WorkoutType.situps:
        return situpsTarget.toDouble();
      case WorkoutType.pullups:
        return pullupsTarget.toDouble();
    }
  }
}

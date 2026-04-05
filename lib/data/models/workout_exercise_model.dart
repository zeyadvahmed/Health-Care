// ============================================================
// workout_exercise_model.dart
// Junction model linking a workout to an exercise.
// Stores the user's chosen sets, reps, weight, rest time,
// and display order for that exercise inside the workout.
//
// Usage:
//   WorkoutExerciseModel we = WorkoutExerciseModel.fromMap(map);
//   map = we.toMap();       // save to SQLite
//   map = we.toFirestore(); // push to Firestore
//
// Rules:
//   - workoutId is foreign key → workouts table
//   - exerciseId is foreign key → exercises table
//   - weight is nullable — null means bodyweight exercise
//   - orderIndex controls display order inside the workout (0-based)
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutExerciseModel {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int sets;
  final int reps;
  final double? weight;
  final int restSeconds;
  final int orderIndex;
  final DateTime updatedAt;
  final bool isSynced;

  WorkoutExerciseModel({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    this.sets = 3,
    this.reps = 10,
    this.weight,
    this.restSeconds = 60,
    this.orderIndex = 0,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'orderIndex': orderIndex,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a WorkoutExerciseModel from a SQLite row map.
  // ----------------------------------------------------------
  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseModel(
      id: map['id'],
      workoutId: map['workoutId'],
      exerciseId: map['exerciseId'],
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      weight: map['weight'],
      restSeconds: map['restSeconds'] ?? 60,
      orderIndex: map['orderIndex'] ?? 0,
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'orderIndex': orderIndex,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a WorkoutExerciseModel from a Firestore document map.
  // ----------------------------------------------------------
  factory WorkoutExerciseModel.fromFirestore(Map<String, dynamic> map) {
    return WorkoutExerciseModel(
      id: map['id'],
      workoutId: map['workoutId'],
      exerciseId: map['exerciseId'],
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      weight: map['weight'],
      restSeconds: map['restSeconds'] ?? 60,
      orderIndex: map['orderIndex'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new WorkoutExerciseModel with only specified fields changed.
  // Used when user edits sets, reps, or weight in the workout editor.
  // ----------------------------------------------------------
  WorkoutExerciseModel copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    int? orderIndex,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return WorkoutExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
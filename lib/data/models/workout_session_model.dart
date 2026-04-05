// ============================================================
// workout_session_model.dart
// Represents one workout session — active or completed.
// Created when user taps Start Workout, updated when they finish.
//
// Usage:
//   WorkoutSessionModel s = WorkoutSessionModel.fromMap(map);
//   map = s.toMap();       // save to SQLite
//   map = s.toFirestore(); // push to Firestore
//   s = s.copyWith(endTime: DateTime.now()); // mark as finished
//
// Rules:
//   - endTime is null while session is active
//   - totalVolume = sum of (sets × reps × weight) — set by controller
//   - totalDuration is in seconds
//   - caloriesBurned estimated via Helpers.caloriesBurned()
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSessionModel {
  final String id;
  final String workoutId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalVolume;
  final int totalDuration;
  final int caloriesBurned;
  final DateTime updatedAt;
  final bool isSynced;

  WorkoutSessionModel({
    required this.id,
    required this.workoutId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.totalVolume = 0,
    this.totalDuration = 0,
    this.caloriesBurned = 0,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // endTime stored as null if session is still active.
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalVolume': totalVolume,
      'totalDuration': totalDuration,
      'caloriesBurned': caloriesBurned,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a WorkoutSessionModel from a SQLite row map.
  // endTime parsed only if not null.
  // ----------------------------------------------------------
  factory WorkoutSessionModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'],
      workoutId: map['workoutId'],
      userId: map['userId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      totalVolume: map['totalVolume'] ?? 0,
      totalDuration: map['totalDuration'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
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
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'totalVolume': totalVolume,
      'totalDuration': totalDuration,
      'caloriesBurned': caloriesBurned,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a WorkoutSessionModel from a Firestore document map.
  // ----------------------------------------------------------
  factory WorkoutSessionModel.fromFirestore(Map<String, dynamic> map) {
    return WorkoutSessionModel(
      id: map['id'],
      workoutId: map['workoutId'],
      userId: map['userId'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      totalVolume: map['totalVolume'] ?? 0,
      totalDuration: map['totalDuration'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new WorkoutSessionModel with only specified fields changed.
  // Used by workout_controller when finishing a session to set
  // endTime, totalVolume, totalDuration, and caloriesBurned.
  // ----------------------------------------------------------
  WorkoutSessionModel copyWith({
    String? id,
    String? workoutId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    double? totalVolume,
    int? totalDuration,
    int? caloriesBurned,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalVolume: totalVolume ?? this.totalVolume,
      totalDuration: totalDuration ?? this.totalDuration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
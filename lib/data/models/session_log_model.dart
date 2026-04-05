// ============================================================
// session_log_model.dart
// Represents one logged set during an active workout session.
// Created each time the user checks off a set in the session screen.
//
// Usage:
//   SessionLogModel log = SessionLogModel.fromMap(map);
//   map = log.toMap();       // save to SQLite
//   map = log.toFirestore(); // push to Firestore
//
// Rules:
//   - sessionId is foreign key → workout_sessions table
//   - exerciseId is foreign key → exercises table
//   - setNumber is 1-based (Set 1, Set 2, Set 3...)
//   - weight is nullable — null means bodyweight set
//   - isCompleted stored as INTEGER 0/1 in SQLite
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class SessionLogModel {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double? weight;
  final bool isCompleted;
  final DateTime timestamp;
  final DateTime updatedAt;
  final bool isSynced;

  SessionLogModel({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.isCompleted = false,
    required this.timestamp,
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
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a SessionLogModel from a SQLite row map.
  // ----------------------------------------------------------
  factory SessionLogModel.fromMap(Map<String, dynamic> map) {
    return SessionLogModel(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      setNumber: map['setNumber'],
      reps: map['reps'],
      weight: map['weight'],
      isCompleted: map['isCompleted'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
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
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a SessionLogModel from a Firestore document map.
  // ----------------------------------------------------------
  factory SessionLogModel.fromFirestore(Map<String, dynamic> map) {
    return SessionLogModel(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      setNumber: map['setNumber'],
      reps: map['reps'],
      weight: map['weight'],
      isCompleted: map['isCompleted'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new SessionLogModel with only specified fields changed.
  // Used by workout_controller when marking a set as completed.
  // ----------------------------------------------------------
  SessionLogModel copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? setNumber,
    int? reps,
    double? weight,
    bool? isCompleted,
    DateTime? timestamp,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return SessionLogModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
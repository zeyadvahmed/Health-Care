// ============================================================
// workout_model.dart
// Represents a workout template — predefined or user-created.
// Does not hold exercises directly; exercises are linked via
// WorkoutExerciseModel using workoutId as the foreign key.
//
// Usage:
//   WorkoutModel w = WorkoutModel.fromMap(map);       // from SQLite
//   WorkoutModel w = WorkoutModel.fromFirestore(map); // from Firestore
//   map = w.toMap();                                  // save to SQLite
//   map = w.toFirestore();                            // push to Firestore
//   w = w.copyWith(name: 'New Name');                 // update one field
//
// Rules:
//   - id is a UUID string generated at creation time
//   - userId links this workout to the user who created it
//   - isPredefined = true means seeded workout, false = user created
//   - difficulty values: "beginner" | "intermediate" | "expert"
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String difficulty;
  final int durationMinutes;
  final bool isPredefined;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? imageUrl; // optional image URL for workout card

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.difficulty = 'beginner',
    this.durationMinutes = 30,
    this.isPredefined = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.imageUrl,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'durationMinutes': durationMinutes,
      'isPredefined': isPredefined ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'imageUrl': imageUrl,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a WorkoutModel from a SQLite row map.
  // ----------------------------------------------------------
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      difficulty: map['difficulty'] ?? 'beginner',
      durationMinutes: map['durationMinutes'] ?? 30,
      isPredefined: map['isPredefined'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
      imageUrl: map['imageUrl'],
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'durationMinutes': durationMinutes,
      'isPredefined': isPredefined,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
      'imageUrl': imageUrl,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a WorkoutModel from a Firestore document map.
  // ----------------------------------------------------------
  factory WorkoutModel.fromFirestore(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      difficulty: map['difficulty'] ?? 'beginner',
      durationMinutes: map['durationMinutes'] ?? 30,
      isPredefined: map['isPredefined'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
      imageUrl: map['imageUrl'],
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new WorkoutModel with only the specified fields changed.
  // Used by workout_controller when editing a workout.
  // ----------------------------------------------------------
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? difficulty,
    int? durationMinutes,
    bool? isPredefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? imageUrl,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPredefined: isPredefined ?? this.isPredefined,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
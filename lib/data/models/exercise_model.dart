// ============================================================
// exercise_model.dart
// Represents one exercise in the global exercise library.
// Seeded from the exercise JSON database on first app launch.
//
// Usage:
//   ExerciseModel ex = ExerciseModel.fromMap(map);       // from SQLite
//   ExerciseModel ex = ExerciseModel.fromFirestore(map); // from Firestore
//   map = ex.toMap();                                    // save to SQLite
//   map = ex.toFirestore();                              // push to Firestore
//
// Rules:
//   - id matches the exercise DB id e.g. "3_4_Sit-Up"
//   - Lists stored as pipe-delimited strings in SQLite: "chest|shoulders"
//   - imageUrl stores relative path only: "3_4_Sit-Up/0.jpg"
//   - No userId — exercises are global, shared across all users
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String category;
  final String level;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String imageUrl;
  final DateTime updatedAt;
  final bool isSynced;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.imageUrl,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // Lists → pipe-delimited strings e.g. "chest|shoulders"
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'level': level,
      'equipment': equipment,
      'primaryMuscles': primaryMuscles.join('|'),
      'secondaryMuscles': secondaryMuscles.join('|'),
      'instructions': instructions.join('|'),
      'imageUrl': imageUrl,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds an ExerciseModel from a SQLite row map.
  // Pipe-delimited strings → split back into List<String>.
  // Empty strings produce an empty list, not a list with one empty item.
  // ----------------------------------------------------------
  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? '',
      level: map['level'] ?? '',
      equipment: map['equipment'] ?? '',
      primaryMuscles:
          map['primaryMuscles'] != null && map['primaryMuscles'] != ''
          ? (map['primaryMuscles'] as String).split('|')
          : [],
      secondaryMuscles:
          map['secondaryMuscles'] != null && map['secondaryMuscles'] != ''
          ? (map['secondaryMuscles'] as String).split('|')
          : [],
      instructions: map['instructions'] != null && map['instructions'] != ''
          ? (map['instructions'] as String).split('|')
          : [],
      imageUrl: map['imageUrl'] ?? '',
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // Lists stored as actual Firestore arrays, not delimited strings.
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'level': level,
      'equipment': equipment,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds an ExerciseModel from a Firestore document map.
  // Firestore arrays → cast directly to List<String>.
  // ----------------------------------------------------------
  factory ExerciseModel.fromFirestore(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? '',
      level: map['level'] ?? '',
      equipment: map['equipment'] ?? '',
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new ExerciseModel with only the specified fields changed.
  // ----------------------------------------------------------
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? category,
    String? level,
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    List<String>? instructions,
    String? imageUrl,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

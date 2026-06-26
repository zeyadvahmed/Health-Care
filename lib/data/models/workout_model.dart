// ============================================================
// workout_model.dart
// Represents one workout template — predefined or user-created.
//
// Usage:
//   WorkoutModel w = WorkoutModel.fromMap(map);       // from SQLite
//   WorkoutModel w = WorkoutModel.fromFirestore(map); // from Firestore
//   map = w.toMap();                                  // save to SQLite
//   map = w.toFirestore();                            // push to Firestore
//   w = w.copyWith(name: 'New Name');                 // update one field
//
// Rules:
//   - id is UUID string (TEXT PRIMARY KEY in SQLite)
//   - userId = '' for predefined workouts, real UID for user workouts
//   - isPredefined: true = seeded system workout, false = user-created
//   - imageUrl is nullable — predefined workouts may have one
//   - difficulty: 'beginner' | 'intermediate' | 'expert'
//   - durationMinutes: estimated session length in minutes
//   - isSynced stored as INTEGER 0/1 in SQLite
//   - DateTimes stored as ISO 8601 strings in SQLite
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
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.difficulty = 'beginner',
    this.durationMinutes = 30,
    this.isPredefined = false,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // Booleans → INTEGER (1/0), DateTimes → ISO 8601 string.
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
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a WorkoutModel from a SQLite row map.
  // Called when reading workouts from the local database.
  // ----------------------------------------------------------
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      name: map['name'],
      description: map['description'],
      difficulty: map['difficulty'] ?? 'beginner',
      durationMinutes: map['durationMinutes'] ?? 30,
      isPredefined: map['isPredefined'] == 1,
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // DateTimes → Firestore Timestamp, isSynced always true here.
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
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a WorkoutModel from a Firestore document map.
  // Called during restoreFromFirestore() on fresh install.
  // ----------------------------------------------------------
  factory WorkoutModel.fromFirestore(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      name: map['name'],
      description: map['description'],
      difficulty: map['difficulty'] ?? 'beginner',
      durationMinutes: map['durationMinutes'] ?? 30,
      isPredefined: map['isPredefined'] ?? false,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new WorkoutModel with only specified fields changed.
  //
  // DESCRIPTION SENTINEL:
  //   Standard ?? pattern cannot clear a nullable field back to null
  //   because null ?? this.description returns the old value.
  //   Solution: use a private sentinel object. If the caller passes
  //   clearDescription: true, description is set to null regardless
  //   of what the description param is.
  //
  //   Example — clear description:
  //     workout.copyWith(clearDescription: true)
  //   Example — update description:
  //     workout.copyWith(description: 'New focus')
  //   Example — leave description unchanged:
  //     workout.copyWith(name: 'New name')
  // ----------------------------------------------------------
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    bool clearDescription = false,
    String? difficulty,
    int? durationMinutes,
    bool? isPredefined,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isPredefined: isPredefined ?? this.isPredefined,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

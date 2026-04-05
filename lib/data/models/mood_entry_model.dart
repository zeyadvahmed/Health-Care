// ============================================================
// mood_entry_model.dart
// Represents one mood log entry saved from mental_health_screen.
//
// Usage:
//   MoodEntryModel entry = MoodEntryModel.fromMap(map);
//   map = entry.toMap();       // save to SQLite
//   map = entry.toFirestore(); // push to Firestore
//
// Rules:
//   - mood values: "happy" | "calm" | "tired" | "stressed"
//   - note is nullable — user can log mood without a reflection note
//   - timestamp used by local_mood_service to query last 7 days for chart
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntryModel {
  final String id;
  final String userId;
  final String mood;
  final String? note;
  final DateTime timestamp;
  final DateTime updatedAt;
  final bool isSynced;

  MoodEntryModel({
    required this.id,
    required this.userId,
    required this.mood,
    this.note,
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
      'userId': userId,
      'mood': mood,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a MoodEntryModel from a SQLite row map.
  // ----------------------------------------------------------
  factory MoodEntryModel.fromMap(Map<String, dynamic> map) {
    return MoodEntryModel(
      id: map['id'],
      userId: map['userId'],
      mood: map['mood'],
      note: map['note'],
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
      'userId': userId,
      'mood': mood,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a MoodEntryModel from a Firestore document map.
  // ----------------------------------------------------------
  factory MoodEntryModel.fromFirestore(Map<String, dynamic> map) {
    return MoodEntryModel(
      id: map['id'],
      userId: map['userId'],
      mood: map['mood'],
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new MoodEntryModel with only specified fields changed.
  // ----------------------------------------------------------
  MoodEntryModel copyWith({
    String? id,
    String? userId,
    String? mood,
    String? note,
    DateTime? timestamp,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

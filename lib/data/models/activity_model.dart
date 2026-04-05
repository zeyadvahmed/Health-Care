// ============================================================
// activity_model.dart
// Represents a user's XP and level progress.
// One record per user. Updated by workout_controller after
// every completed workout session.
//
// Usage:
//   ActivityModel activity = ActivityModel.fromMap(map);
//   map = activity.toMap();       // save to SQLite
//   map = activity.toFirestore(); // push to Firestore
//   activity = activity.copyWith(totalXp: 600); // update XP
//
// Rules:
//   - One record per userId — created on first workout completion
//   - Each completed workout awards 100 XP flat
//   - Level formula: currentLevel = totalXp ~/ 500  (integer division)
//   - xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String userId;
  final int totalXp;
  final int currentLevel;
  final int xpToNextLevel;
  final DateTime updatedAt;
  final bool isSynced;

  ActivityModel({
    required this.id,
    required this.userId,
    this.totalXp = 0,
    this.currentLevel = 0,
    this.xpToNextLevel = 500,
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
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'xpToNextLevel': xpToNextLevel,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds an ActivityModel from a SQLite row map.
  // ----------------------------------------------------------
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      userId: map['userId'],
      totalXp: map['totalXp'] ?? 0,
      currentLevel: map['currentLevel'] ?? 0,
      xpToNextLevel: map['xpToNextLevel'] ?? 500,
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
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'xpToNextLevel': xpToNextLevel,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds an ActivityModel from a Firestore document map.
  // ----------------------------------------------------------
  factory ActivityModel.fromFirestore(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      userId: map['userId'],
      totalXp: map['totalXp'] ?? 0,
      currentLevel: map['currentLevel'] ?? 0,
      xpToNextLevel: map['xpToNextLevel'] ?? 500,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new ActivityModel with only specified fields changed.
  // Used by workout_controller after awarding XP on session completion.
  // ----------------------------------------------------------
  ActivityModel copyWith({
    String? id,
    String? userId,
    int? totalXp,
    int? currentLevel,
    int? xpToNextLevel,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

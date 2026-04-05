// ============================================================
// hydration_entry_model.dart
// Represents one water intake log entry.
// Created each time user taps the 250ml or 500ml button.
//
// Usage:
//   HydrationEntryModel entry = HydrationEntryModel.fromMap(map);
//   map = entry.toMap();       // save to SQLite
//   map = entry.toFirestore(); // push to Firestore
//
// Rules:
//   - type values: "250ml" | "500ml"
//   - dailyGoalMl stored per entry to preserve historical accuracy
//   - timestamp used to filter today's entries in local_hydration_service
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class HydrationEntryModel {
  final String id;
  final String userId;
  final int amountMl;
  final String type;
  final int dailyGoalMl;
  final DateTime timestamp;
  final DateTime updatedAt;
  final bool isSynced;

  HydrationEntryModel({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.type,
    required this.dailyGoalMl,
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
      'amountMl': amountMl,
      'type': type,
      'dailyGoalMl': dailyGoalMl,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a HydrationEntryModel from a SQLite row map.
  // ----------------------------------------------------------
  factory HydrationEntryModel.fromMap(Map<String, dynamic> map) {
    return HydrationEntryModel(
      id: map['id'],
      userId: map['userId'],
      amountMl: map['amountMl'],
      type: map['type'] ?? '250ml',
      dailyGoalMl: map['dailyGoalMl'] ?? 2500,
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
      'amountMl': amountMl,
      'type': type,
      'dailyGoalMl': dailyGoalMl,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a HydrationEntryModel from a Firestore document map.
  // ----------------------------------------------------------
  factory HydrationEntryModel.fromFirestore(Map<String, dynamic> map) {
    return HydrationEntryModel(
      id: map['id'],
      userId: map['userId'],
      amountMl: map['amountMl'],
      type: map['type'] ?? '250ml',
      dailyGoalMl: map['dailyGoalMl'] ?? 2500,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new HydrationEntryModel with only specified fields changed.
  // ----------------------------------------------------------
  HydrationEntryModel copyWith({
    String? id,
    String? userId,
    int? amountMl,
    String? type,
    int? dailyGoalMl,
    DateTime? timestamp,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return HydrationEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountMl: amountMl ?? this.amountMl,
      type: type ?? this.type,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

// ============================================================
// medical_record_model.dart
// Represents one medication or medical record for a user.
// Created from add_medication_screen, displayed in medical_tracker_screen.
//
// Usage:
//   MedicalRecordModel record = MedicalRecordModel.fromMap(map);
//   map = record.toMap();       // save to SQLite
//   map = record.toFirestore(); // push to Firestore
//
// Rules:
//   - type values: "pill" | "injection" | "supplement" | "other"
//   - frequency values: "once_daily" | "twice_daily" | "every_x_hours"
//   - scheduleTimes stored as pipe-delimited string in SQLite: "08:00|20:00"
//   - endDate is nullable — open-ended medications have no end date
//   - startDate and endDate stored as "yyyy-MM-dd" strings in SQLite
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String dosage;
  final String frequency;
  final List<String> scheduleTimes;
  final String startDate;
  final String? endDate;
  final DateTime updatedAt;
  final bool isSynced;

  MedicalRecordModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.dosage,
    required this.frequency,
    required this.scheduleTimes,
    required this.startDate,
    this.endDate,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // scheduleTimes list → pipe-delimited string e.g. "08:00|20:00"
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'dosage': dosage,
      'frequency': frequency,
      'scheduleTimes': scheduleTimes.join('|'),
      'startDate': startDate,
      'endDate': endDate,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a MedicalRecordModel from a SQLite row map.
  // Pipe-delimited scheduleTimes → split back to List<String>.
  // ----------------------------------------------------------
  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      type: map['type'] ?? 'pill',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'once_daily',
      scheduleTimes: map['scheduleTimes'] != null && map['scheduleTimes'] != ''
          ? (map['scheduleTimes'] as String).split('|')
          : [],
      startDate: map['startDate'],
      endDate: map['endDate'],
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // scheduleTimes stored as Firestore array.
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'dosage': dosage,
      'frequency': frequency,
      'scheduleTimes': scheduleTimes,
      'startDate': startDate,
      'endDate': endDate,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a MedicalRecordModel from a Firestore document map.
  // ----------------------------------------------------------
  factory MedicalRecordModel.fromFirestore(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      type: map['type'] ?? 'pill',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? 'once_daily',
      scheduleTimes: List<String>.from(map['scheduleTimes'] ?? []),
      startDate: map['startDate'],
      endDate: map['endDate'],
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new MedicalRecordModel with only specified fields changed.
  // Used by medical_controller when editing a medication.
  // ----------------------------------------------------------
  MedicalRecordModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? dosage,
    String? frequency,
    List<String>? scheduleTimes,
    String? startDate,
    String? endDate,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

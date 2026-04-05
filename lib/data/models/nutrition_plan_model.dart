// ============================================================
// nutrition_plan_model.dart
// Represents the daily nutrition summary for one user on one date.
// One plan per user per day. Meals are linked via planId.
//
// Usage:
//   NutritionPlanModel plan = NutritionPlanModel.fromMap(map);
//   map = plan.toMap();       // save to SQLite
//   map = plan.toFirestore(); // push to Firestore
//   plan = plan.copyWith(totalCalories: 1800); // update totals
//
// Rules:
//   - date stored as "yyyy-MM-dd" string for easy daily queries
//   - totals are recalculated by nutrition_controller on every meal change
//   - one plan per userId + date combination — enforced by controller
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionPlanModel {
  final String id;
  final String userId;
  final String date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final DateTime updatedAt;
  final bool isSynced;

  NutritionPlanModel({
    required this.id,
    required this.userId,
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFats = 0,
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
      'date': date,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a NutritionPlanModel from a SQLite row map.
  // ----------------------------------------------------------
  factory NutritionPlanModel.fromMap(Map<String, dynamic> map) {
    return NutritionPlanModel(
      id: map['id'],
      userId: map['userId'],
      date: map['date'],
      totalCalories: map['totalCalories'] ?? 0,
      totalProtein: map['totalProtein'] ?? 0,
      totalCarbs: map['totalCarbs'] ?? 0,
      totalFats: map['totalFats'] ?? 0,
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
      'date': date,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a NutritionPlanModel from a Firestore document map.
  // ----------------------------------------------------------
  factory NutritionPlanModel.fromFirestore(Map<String, dynamic> map) {
    return NutritionPlanModel(
      id: map['id'],
      userId: map['userId'],
      date: map['date'],
      totalCalories: map['totalCalories'] ?? 0,
      totalProtein: map['totalProtein'] ?? 0,
      totalCarbs: map['totalCarbs'] ?? 0,
      totalFats: map['totalFats'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new NutritionPlanModel with only specified fields changed.
  // Used by nutrition_controller after recalculating totals.
  // ----------------------------------------------------------
  NutritionPlanModel copyWith({
    String? id,
    String? userId,
    String? date,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFats,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return NutritionPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFats: totalFats ?? this.totalFats,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
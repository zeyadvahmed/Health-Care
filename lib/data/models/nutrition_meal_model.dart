// ============================================================
// nutrition_meal_model.dart
// Represents one meal entry inside a daily nutrition plan.
// Multiple meals belong to one NutritionPlanModel via planId.
//
// Usage:
//   NutritionMealModel meal = NutritionMealModel.fromMap(map);
//   map = meal.toMap();       // save to SQLite
//   map = meal.toFirestore(); // push to Firestore
//
// Rules:
//   - planId is foreign key → nutrition_plans table
//   - mealType values: "breakfast" | "lunch" | "dinner" | "snack"
//   - protein, carbs, fats are in grams
//   - calories are in kcal
//   - isSynced stored as INTEGER 0/1 in SQLite
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionMealModel {
  final String id;
  final String planId;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String mealType;
  final DateTime updatedAt;
  final bool isSynced;

  NutritionMealModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    required this.mealType,
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
      'planId': planId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a NutritionMealModel from a SQLite row map.
  // ----------------------------------------------------------
  factory NutritionMealModel.fromMap(Map<String, dynamic> map) {
    return NutritionMealModel(
      id: map['id'],
      planId: map['planId'],
      name: map['name'],
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fats: map['fats'] ?? 0,
      mealType: map['mealType'] ?? 'snack',
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
      'planId': planId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a NutritionMealModel from a Firestore document map.
  // ----------------------------------------------------------
  factory NutritionMealModel.fromFirestore(Map<String, dynamic> map) {
    return NutritionMealModel(
      id: map['id'],
      planId: map['planId'],
      name: map['name'],
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fats: map['fats'] ?? 0,
      mealType: map['mealType'] ?? 'snack',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new NutritionMealModel with only specified fields changed.
  // ----------------------------------------------------------
  NutritionMealModel copyWith({
    String? id,
    String? planId,
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
    String? mealType,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return NutritionMealModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      mealType: mealType ?? this.mealType,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
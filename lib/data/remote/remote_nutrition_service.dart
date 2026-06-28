// ============================================================
// remote_nutrition_service.dart
// Firestore read/write operations for nutrition data.
//
// Food items and daily goals are stored under each Firebase user:
//   users/{uid}/food_items/{id}
//   users/{uid}/daily_goals/default
//
// The public methods mirror LocalNutritionService, with uid added so
// Firestore data stays scoped to the signed-in user.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/daily_goal.dart';
import 'package:sparksteel/data/models/food_item.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteNutritionService {
  RemoteNutritionService._internal();
  static final RemoteNutritionService instance =
      RemoteNutritionService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _foodItemsPath(String uid) => 'User/$uid/food_items';
  String _dailyGoalsPath(String uid) => 'User/$uid/daily_goals';

  static const int _batchSize = 450;

  // Food Items

  Future<String> insertFoodItem(String uid, FoodItem item) async {
    final data = item.toMap();
    final id = item.id?.toString();

    if (id == null) {
      final doc = await _db.collection(_foodItemsPath(uid)).add(data);
      return doc.id;
    }

    await FirestoreService.instance.setDocument(
      _foodItemsPath(uid),
      id,
      data,
    );
    return id;
  }

  Future<List<FoodItem>> getFoodItemsByDateAndMeal(
    String uid,
    String date,
    String mealType,
  ) async {
    final snapshot = await _db
        .collection(_foodItemsPath(uid))
        .where('date', isEqualTo: date)
        .where('meal_type', isEqualTo: mealType)
        .get();

    final items = snapshot.docs.map((doc) => _foodItemFromDoc(doc)).toList();
    items.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return items;
  }

  Future<List<FoodItem>> getFoodItemsByDate(String uid, String date) async {
    final snapshot = await _db
        .collection(_foodItemsPath(uid))
        .where('date', isEqualTo: date)
        .get();

    final items = snapshot.docs.map((doc) => _foodItemFromDoc(doc)).toList();
    items.sort((a, b) {
      final mealCompare = a.mealType.compareTo(b.mealType);
      if (mealCompare != 0) return mealCompare;
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return items;
  }

  Future<List<FoodItem>> getAllFoodItems(String uid) async {
    final snapshot = await _db.collection(_foodItemsPath(uid)).get();

    final items = snapshot.docs.map((doc) => _foodItemFromDoc(doc)).toList();
    items.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      final mealCompare = a.mealType.compareTo(b.mealType);
      if (mealCompare != 0) return mealCompare;
      return (a.id ?? 0).compareTo(b.id ?? 0);
    });
    return items;
  }

  Future<double> getTotalCaloriesForDate(String uid, String date) async {
    final items = await getFoodItemsByDate(uid, date);
    return items.fold<double>(0, (total, item) => total + item.calories);
  }

  Future<double> getTotalCaloriesForDateAndMeal(
    String uid,
    String date,
    String mealType,
  ) async {
    final items = await getFoodItemsByDateAndMeal(uid, date, mealType);
    return items.fold<double>(0, (total, item) => total + item.calories);
  }

  Future<void> updateFoodItem(String uid, FoodItem item) async {
    final id = item.id;
    if (id == null) {
      throw ArgumentError('FoodItem.id is required for remote update.');
    }

    await FirestoreService.instance.updateDocument(
      _foodItemsPath(uid),
      id.toString(),
      item.toMap(),
    );
  }

  Future<void> deleteFoodItem(String uid, int id) async {
    await FirestoreService.instance.deleteDocument(
      _foodItemsPath(uid),
      id.toString(),
    );
  }

  Future<void> clear(String uid) async {
    final snapshot = await _db.collection(_foodItemsPath(uid)).get();
    if (snapshot.docs.isEmpty) return;

    final operations = snapshot.docs
        .map(
          (doc) => {
            'type': 'delete',
            'collection': _foodItemsPath(uid),
            'docId': doc.id,
          },
        )
        .toList();

    await _batchWriteInChunks(operations);
  }

  Future<void> pushAllFoodItems(String uid, List<FoodItem> items) async {
    final collection = _foodItemsPath(uid);
    final snapshot = await _db.collection(collection).get();
    final localIds = items
        .where((item) => item.id != null)
        .map((item) => item.id.toString())
        .toSet();

    final operations = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      if (!localIds.contains(doc.id)) {
        operations.add({
          'type': 'delete',
          'collection': collection,
          'docId': doc.id,
        });
      }
    }

    for (final item in items) {
      final id = item.id;
      if (id == null) continue;
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': id.toString(),
        'data': item.toMap(),
      });
    }

    await _batchWriteInChunks(operations);
  }

  // Daily Goals

  Future<DailyGoal> getDailyGoal(String uid) async {
    final data = await FirestoreService.instance.getDocument(
      _dailyGoalsPath(uid),
      'default',
    );

    if (data == null) {
      return const DailyGoal(targetCalories: 2000);
    }

    return DailyGoal.fromMap(_normalizeDailyGoalMap(data));
  }

  Future<void> updateDailyGoal(String uid, DailyGoal goal) async {
    await FirestoreService.instance.setDocument(
      _dailyGoalsPath(uid),
      'default',
      goal.toMap(),
    );
  }


  FoodItem _foodItemFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = _intValue(data['id']) ?? int.tryParse(doc.id);
    data['calories'] = _doubleValue(data['calories']);
    return FoodItem.fromMap(data);
  }

  Map<String, dynamic> _normalizeDailyGoalMap(Map<String, dynamic> data) {
    return {
      'id': _intValue(data['id']),
      'target_calories': _doubleValue(data['target_calories']),
    };
  }

  int? _intValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double _doubleValue(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Future<void> _batchWriteInChunks(
    List<Map<String, dynamic>> operations,
  ) async {
    if (operations.isEmpty) return;

    for (var i = 0; i < operations.length; i += _batchSize) {
      final end = i + _batchSize < operations.length
          ? i + _batchSize
          : operations.length;
      await FirestoreService.instance.batchWrite(operations.sublist(i, end));
    }
  }
}

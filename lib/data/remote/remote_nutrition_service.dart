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
import 'package:sparksteel/data/models/food_item.dart';
import 'package:sparksteel/data/models/daily_goal.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteNutritionService {
  RemoteNutritionService._internal();
  static final RemoteNutritionService instance =
      RemoteNutritionService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _foodItemsPath(String uid) => 'User/$uid/food_items';
  String _dailyGoalsPath(String uid) => 'User/$uid/daily_goals';

  FoodItem _foodItemFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final map = Map<String, dynamic>.from(data);
    // try to parse id from document id if possible
    final parsedId = int.tryParse(doc.id);
    map['id'] = parsedId ?? map['id'];
    // normalize field names
    if (map.containsKey('meal_type') == false && map.containsKey('mealType')) {
      map['meal_type'] = map['mealType'];
    }
    if (map.containsKey('calories') && map['calories'] is int) {
      map['calories'] = (map['calories'] as int).toDouble();
    }
    return FoodItem.fromMap(map);
  }
  

  Future<void> pushAllFoodItems(String uid, List<FoodItem> items) async {
    final collection = _foodItemsPath(uid);
    final snapshot = await _db.collection(collection).get();

    final remoteIds = snapshot.docs.map((d) => d.id).toSet();
    final localIds = items
        .where((i) => i.id != null)
        .map((i) => i.id.toString())
        .toSet();

  
    for (final docId in remoteIds.difference(localIds)) {
      await FirestoreService.instance.deleteDocument(collection, docId);
    }

  
    for (final item in items) {
      final id = item.id;
      if (id == null) continue;
      await FirestoreService.instance.setDocument(
        collection,
        id.toString(),
        item.toMap(),
      );
    }
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

    Map<String, dynamic> _normalizeDailyGoalMap(Map<String, dynamic> data) {
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey('targetCalories') && !map.containsKey('target_calories')) {
        map['target_calories'] = map['targetCalories'];
      }
      return map;
    }
}

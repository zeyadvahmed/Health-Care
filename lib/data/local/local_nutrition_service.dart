// ============================================================
// local_nutrition_service.dart
// All SQLite read/write operations for nutrition_plans and nutrition_meals tables.
//
// Usage:
//   await LocalNutritionService.instance.insertPlan(plan);
//   final plan = await LocalNutritionService.instance.getPlanByDate(userId, date);
//   await LocalNutritionService.instance.insertMeal(meal);
//
// Methods to implement:
//   insertPlan(NutritionPlanModel)               — insert one plan row
//   getPlanByDate(String userId, String date)    — return plan for userId + date
//                                                  returns null if none exists yet
//   updatePlan(NutritionPlanModel)               — update totals after meal change
//   getUnsyncedPlans()                           — WHERE isSynced = 0
//   markPlanSynced(String id)                    — UPDATE isSynced = 1
//
//   insertMeal(NutritionMealModel)               — insert one meal row
//   getMealsForPlan(String planId)               — return all meals for a plan
//   updateMeal(NutritionMealModel)               — update meal row
//   deleteMeal(String id)                        — delete meal by id
//   getUnsyncedMeals()                           — WHERE isSynced = 0
//   markMealSynced(String id)                    — UPDATE isSynced = 1
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getPlanByDate uses WHERE userId = ? AND date = ? — returns first result or null
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
import 'package:sparksteel/data/local/database_helper.dart';
import 'package:sparksteel/data/models/daily_goal.dart';
import 'package:sparksteel/data/models/food_item.dart';

class LocalNutritionService {
  Future<int> insertFoodItem(FoodItem item) async {
    final db = await DatabaseHelper.instance.database;
    final data = item.toMap();
    if (item.id == null) {
      data.remove('id');
    }
    return await db.insert('food_items', data);
  }

  Future<List<FoodItem>> getFoodItemsByDateAndMeal(
    String date,
    String mealType,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'food_items',
      where: 'date = ? AND meal_type = ?',
      whereArgs: [date, mealType],
      orderBy: 'id ASC',
    );
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getFoodItemsByDate(String date) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'food_items',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'meal_type ASC, id ASC',
    );
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'food_items',
      orderBy: 'date ASC, meal_type ASC, id ASC',
    );
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<double> getTotalCaloriesForDate(String date) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM food_items WHERE date = ?',
      [date],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalCaloriesForDateAndMeal(
    String date,
    String mealType,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM food_items WHERE date = ? AND meal_type = ?',
      [date, mealType],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> updateFoodItem(FoodItem item) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clear() async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('food_items');
  }

  // ─── Daily Goals ───────────────────────────────────────────────────────────

  Future<DailyGoal> getDailyGoal() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('daily_goals', limit: 1);
    if (maps.isEmpty) {
      return const DailyGoal(targetCalories: 2000);
    }
    return DailyGoal.fromMap(maps.first);
  }

  Future<int> updateDailyGoal(DailyGoal goal) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'daily_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> close() async {
    final db = await DatabaseHelper.instance.database;
    db.close();
  }
}

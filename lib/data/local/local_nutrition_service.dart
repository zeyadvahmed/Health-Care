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
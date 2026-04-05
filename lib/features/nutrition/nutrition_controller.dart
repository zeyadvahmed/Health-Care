// ============================================================
// nutrition_controller.dart
// Manages daily nutrition plan and meal entries.
//
// Usage:
//   final controller = NutritionController();
//   await controller.loadTodayPlan(userId);
//   await controller.addMeal(planId, meal);
//   await controller.deleteMeal(mealId);
//
// State to expose:
//   bool isLoading                      — true while loading
//   NutritionPlanModel? todayPlan       — today's nutrition plan
//   List<NutritionMealModel> meals      — all meals for today's plan
//
// Methods to implement:
//   loadTodayPlan(String userId)         — get or create today's plan from SQLite
//   addMeal(String planId,               — insert meal, recalculate plan totals,
//           NutritionMealModel meal)       update plan in SQLite, call sync
//   deleteMeal(String mealId)            — delete meal, recalculate totals,
//                                          update plan in SQLite, call sync
//   _recalculateTotals()                 — private: sum all meals and update plan
//
// Rules:
//   - loadTodayPlan creates a new plan if none exists for today
//   - Always call sync_service.syncAll() after every change
//   - No Flutter UI imports except material.dart if needed
// ============================================================
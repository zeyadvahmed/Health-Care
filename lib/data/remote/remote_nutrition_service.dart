// ============================================================
// remote_nutrition_service.dart
// Firestore push methods for nutrition plans and meals.
//
// Usage:
//   await RemoteNutritionService.instance.pushPlan(plan);
//   await RemoteNutritionService.instance.pushMeal(meal);
//   await RemoteNutritionService.instance.deletePlan(id);
//
// Methods to implement:
//   pushPlan(NutritionPlanModel)     — write plan to 'nutrition_plans' collection
//   pushMeal(NutritionMealModel)     — write meal to 'nutrition_meals' collection
//   deletePlan(String id)            — delete plan doc from Firestore
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
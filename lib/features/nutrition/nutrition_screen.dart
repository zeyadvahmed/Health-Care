// ============================================================
// nutrition_screen.dart
// Daily nutrition tracking screen.
//
// What to build:
//   - CustomAppBar title: 'Nutrition'
//   - CircularTracker for calories consumed vs goal
//   - Row of 3 macro cards: Protein / Carbs / Fats with CustomProgressBar each
//   - 4 MealCards: Breakfast, Lunch, Dinner, Snacks
//     each card shows food items and Add Food button
//     Add Food → show AddFoodScreen as bottom sheet
//     → on return with meal → nutritionController.addMeal(planId, meal)
//
// Controller usage:
//   - Call nutritionController.loadTodayPlan(userId) in initState
//   - Show LoadingWidget while isLoading is true
//
// Rules:
//   - StatefulWidget — totals change when meals are added or removed
//   - Background color: AppColors.background
// ============================================================
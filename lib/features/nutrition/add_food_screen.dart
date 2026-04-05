// ============================================================
// add_food_screen.dart
// Bottom sheet overlay for logging a food item.
//
// What to build:
//   - Drag handle at top
//   - Title 'Add Food'
//   - Food name CustomTextField (validator: Validators.validateFoodName)
//   - Calories CustomTextField (validator: Validators.validateCalories,
//                               keyboardType: numeric)
//   - Optional: Protein / Carbs / Fats fields
//   - Meal type chips: Breakfast / Lunch / Dinner / Snack (single select)
//   - Save CustomButton at bottom
//     → Navigator.pop(context, meal) to return NutritionMealModel
//
// Rules:
//   - StatefulWidget — text controllers, chip selection, form validation
//   - Shown as a bottom sheet from nutrition_screen, not navigated to
//   - Returns NutritionMealModel via pop, does not save to DB itself
//   - Background color: AppColors.cardBackground
// ============================================================
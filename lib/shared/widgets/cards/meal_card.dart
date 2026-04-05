// ============================================================
// meal_card.dart
// Accordion card for one meal type showing food items inside.
//
// Usage:
//   MealCard(
//     mealType: 'breakfast',
//     totalCalories: 450,
//     meals: breakfastMeals,
//     onAddFood: () => _showAddFoodSheet(context, 'breakfast'),
//   )
//
// Parameters:
//   mealType      — "breakfast" | "lunch" | "dinner" | "snack" (required)
//   totalCalories — total kcal for this meal type (required)
//   meals         — list of NutritionMealModel for this type (required)
//   onAddFood     — callback when Add Food button is tapped (required)
//
// What to build:
//   - Header row: meal type icon, name capitalized, total calories, expand arrow
//   - Expanded body: list of food items each showing name and calories
//     with a delete icon per item
//   - Add Food button at the bottom of expanded body
//
// Rules:
//   - StatelessWidget — expand/collapse state managed by parent nutrition_screen
//   - Meal type icons: breakfast=☀️, lunch=🌤️, dinner=🌙, snack=🍎
//   - Use AppColors for all colors
// ============================================================
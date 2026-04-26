// ============================================================
// meal_card.dart
// lib/shared/widgets/cards/meal_card.dart
//
// PURPOSE:
//   Accordion card for one meal type (breakfast/lunch/dinner/snack).
//   Shows the meal icon, name, total calories, and a list of
//   all food items logged under that meal type.
//
// USED IN:
//   nutrition_screen.dart — one MealCard per meal type (4 total)
//
// EXPAND/COLLAPSE:
//   This widget is StatelessWidget — it does NOT manage its own
//   open/closed state. The parent nutrition_screen holds a
//   Set<String> of expanded meal types and passes isExpanded in.
//   When the header is tapped, onToggle fires and the parent
//   calls setState to flip the expanded state.
//
// PARAMETERS:
//   mealType      — "breakfast" | "lunch" | "dinner" | "snack"
//   totalCalories — sum of kcal for all meals of this type
//   meals         — list of NutritionMealModel for this type
//   onAddFood     — called when user taps Add Food button
//   onDeleteMeal  — called with meal id when user taps delete icon
//   isExpanded    — whether the body is currently visible
//   onToggle      — called when user taps the header to expand/collapse
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/nutrition_meal_model.dart';

class MealCard extends StatelessWidget {
  final String mealType;
  final int totalCalories;
  final List<NutritionMealModel> meals;
  final VoidCallback onAddFood;
  final void Function(String mealId) onDeleteMeal;
  final bool isExpanded;
  final VoidCallback onToggle;

  const MealCard({
    super.key,
    required this.mealType,
    required this.totalCalories,
    required this.meals,
    required this.onAddFood,
    required this.onDeleteMeal,
    required this.isExpanded,
    required this.onToggle,
  });

  // ----------------------------------------------------------
  // _icon()
  // Returns the icon for each meal type.
  // breakfast → sun (morning meal)
  // lunch     → partly cloudy (midday)
  // dinner    → bedtime (evening meal)
  // snack     → apple (light bite)
  // ----------------------------------------------------------
  IconData _icon() {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return Icons.wb_sunny_rounded;
      case 'lunch':     return Icons.wb_cloudy_rounded;
      case 'dinner':    return Icons.bedtime_rounded;
      case 'snack':     return Icons.apple_rounded;
      default:          return Icons.restaurant_rounded;
    }
  }

  // ----------------------------------------------------------
  // _iconColor()
  // Each meal type gets its own accent color for the icon.
  // ----------------------------------------------------------
  Color _iconColor() {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return const Color(0xFFFFA726); // warm orange
      case 'lunch':     return const Color(0xFF29B6F6); // sky blue
      case 'dinner':    return const Color(0xFF7E57C2); // purple
      case 'snack':     return const Color(0xFF66BB6A); // green
      default:          return AppColors.steelColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _iconColor();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(
        children: [

          // ── Header row — always visible ──────────────────
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [

                  // Meal type icon in colored circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon(), color: color, size: 18),
                  ),
                  const SizedBox(width: 10),

                  // Meal name capitalized
                  Expanded(
                    child: Text(
                      // Capitalize first letter
                      mealType[0].toUpperCase() +
                          mealType.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Total calories for this meal type
                  Text(
                    '$totalCalories kcal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Expand / collapse arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded body — visible only when isExpanded ─
          if (isExpanded) ...[
            Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.divider),

            // Food items list
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No items added yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary
                        .withValues(alpha: 0.4),
                  ),
                ),
              )
            else
              ListView.separated(
                // Inside a Column — must be non-scrollable
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.divider),
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        // Food name
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Calories
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete icon
                        GestureDetector(
                          onTap: () => onDeleteMeal(meal.id),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Add Food button
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: GestureDetector(
                onTap: onAddFood,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.steelColor.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: 16,
                          color: AppColors.steelColor),
                      const SizedBox(width: 6),
                      Text(
                        'Add Food',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.steelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
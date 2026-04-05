// ============================================================
// circular_tracker.dart
// Circular ring progress tracker showing current value vs goal.
// Used for water intake ring and calorie percentage ring.
//
// Usage:
//   CircularTracker(
//     current: 1500,
//     goal: 2500,
//     unit: 'ml',
//     color: AppColors.hydrationColor,
//   )
//   CircularTracker(
//     current: 1800,
//     goal: 2000,
//     unit: 'kcal',
//     color: AppColors.nutritionColor,
//   )
//
// Parameters:
//   current — current value (required)
//   goal    — target value (required)
//   unit    — unit string shown in center below the number (required)
//   color   — ring fill color (required)
//
// Rules:
//   - StatelessWidget — all values passed in, no internal state
//   - Show current value and unit in center of the ring
//   - Show percentage below or inside as secondary text
//   - Background ring color should be AppColors.cardBackground
//   - Clamp progress to 1.0 maximum so ring never overfills
// ============================================================
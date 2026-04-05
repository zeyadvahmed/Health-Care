// ============================================================
// workout_card.dart
// Card displaying a workout in two visual styles.
//
// Usage:
//   WorkoutCard(
//     workout: workout,
//     isPredefined: true,
//     onStart: () => controller.startSession(workout.id, userId),
//     onViewDetails: () => Navigator.push(...),
//   )
//   WorkoutCard(
//     workout: workout,
//     isPredefined: false,
//     onViewDetails: () => Navigator.push(...),
//     onEdit: () => Navigator.pushNamed(context, AppRoutes.createWorkout),
//   )
//
// Parameters:
//   workout       — WorkoutModel to display (required)
//   isPredefined  — true = image card style, false = list tile style (required)
//   onStart       — callback for Start button (predefined only)
//   onViewDetails — callback for View Details button (required)
//   onEdit        — callback for Edit button (my workouts only)
//
// Predefined style:
//   Full background image, difficulty badge overlay,
//   name and description, Start and View Details buttons
//
// My Workout style:
//   Icon, name, difficulty chip, duration, View Details and Edit buttons
//
// Rules:
//   - StatelessWidget — displays passed-in data, no internal state
//   - Use AppColors for all colors
//   - Difficulty badge colors from Helpers.difficultyColor(difficulty)
// ============================================================
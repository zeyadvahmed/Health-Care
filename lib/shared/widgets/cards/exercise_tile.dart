// ============================================================
// exercise_tile.dart
// List tile showing one exercise inside a workout.
//
// Usage:
//   ExerciseTile(
//     exercise: exercise,
//     sets: 3,
//     reps: 10,
//     weight: 80.0,
//     onEdit: () => Navigator.push(...),
//     onDelete: () => controller.deleteExercise(exercise.id),
//   )
//
// Parameters:
//   exercise  — ExerciseModel for name and muscle group (required)
//   sets      — number of sets (required)
//   reps      — number of reps (required)
//   weight    — weight in kg, null if bodyweight (required, nullable)
//   onEdit    — callback for Edit button (required)
//   onDelete  — callback for Delete button (required)
//
// What to build:
//   - Exercise name bold
//   - Muscle group subtitle in grey
//   - Row of chips: sets x reps, weight (or 'Bodyweight'), rest time
//   - Edit and Delete icon buttons on the right
//
// Rules:
//   - StatelessWidget — displays data and calls callbacks, no internal state
//   - Chip colors from AppColors feature palette
// ============================================================
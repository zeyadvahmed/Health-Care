// ============================================================
// exercise_search_result_tile.dart
// Card showing one exercise search result with image and details.
//
// Usage:
//   ExerciseSearchResultTile(
//     exercise: exercise,
//     onTap: () => onExerciseSelected(exercise),
//   )
//
// Parameters:
//   exercise — ExerciseModel to display (required)
//   onTap    — callback fired when tile is tapped (required)
//
// What to build:
//   - Exercise image on the left (from exercise.imageUrl)
//     show placeholder icon if image fails to load
//   - Bold exercise name
//   - Primary muscle group in grey below name
//   - First instruction line as description text (truncated to 2 lines)
//   - Whole tile is tappable
//
// Rules:
//   - StatelessWidget — displays fixed data, no internal state
//   - Image loaded from assets or network based on imageUrl format
//   - Use AppColors for text colors
// ============================================================
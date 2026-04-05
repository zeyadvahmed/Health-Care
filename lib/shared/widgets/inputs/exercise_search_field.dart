// ============================================================
// exercise_search_field.dart
// Inline autocomplete search field for selecting an exercise by name.
// Shows a dropdown overlay of matching exercises as the user types.
//
// Usage:
//   ExerciseSearchField(
//     controller: _exerciseNameController,
//     onExerciseSelected: (exercise) {
//       setState(() => _selectedExercise = exercise);
//     },
//     validator: Validators.validateExerciseName,
//   )
//
// Parameters:
//   controller         — TextEditingController for the input field (required)
//   onExerciseSelected — callback fired with ExerciseModel when user taps a result (required)
//   validator          — validation function for the field (required)
//
// Behavior:
//   - On every keystroke calls workoutController.searchExercises(query)
//   - Shows dropdown list of ExerciseSearchResultTiles below the field
//   - On tile tap: fills the field with exercise name,
//                  calls onExerciseSelected(exercise),
//                  closes the dropdown
//   - Dropdown disappears when field loses focus or query is empty
//
// Rules:
//   - StatefulWidget — dropdown visibility and results list are internal state
//   - Use OverlayEntry or a simple Column with conditional visibility for dropdown
//   - Used inside create_workout_screen and add_exercise_screen
// ============================================================
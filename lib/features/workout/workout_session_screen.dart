// ============================================================
// workout_session_screen.dart
// Active workout session screen with live timer and set logging.
//
// What to build:
//   - CustomAppBar with workout name, pause button, finish button
//   - Running timer counting up every second using Timer.periodic
//   - CustomProgressBar showing sets completed / total sets
//   - Expandable ExerciseTile cards, one per exercise
//     each card shows set rows: set number, reps, weight, checkbox
//     checking a set → workoutController.logSet(...)
//                    → show RestTimerDialog(seconds: exercise.restSeconds)
//   - Finish button → workoutController.finishSession(session, logs)
//                   → Navigator.push to workout_summary_screen
//
// Receives via constructor:
//   WorkoutModel workout
//   List<WorkoutExerciseModel> exercises
//
// Rules:
//   - StatefulWidget — live timer, dynamic checkboxes, expanding cards
//   - Cancel Timer in dispose() to avoid memory leaks
//   - Navigated to via Navigator.push (not pushNamed)
//   - Background color: AppColors.background
// ============================================================
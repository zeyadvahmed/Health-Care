// ============================================================
// local_exercise_service.dart
// All SQLite read/write operations for the exercises table.
//
// Usage:
//   await LocalExerciseService.instance.insertExercise(exercise);
//   final results = await LocalExerciseService.instance.searchExercises('bench');
//   final exercise = await LocalExerciseService.instance.getExerciseById('id');
//
// Methods to implement:
//   insertExercise(ExerciseModel)        — insert one exercise row
//   insertAllExercises(List<Exercise>)   — bulk insert on first launch seeding
//   getAllExercises()                    — return all exercises as List<ExerciseModel>
//   searchExercises(String query)        — LIKE query on name field for autocomplete
//                                          WHERE name LIKE '%query%'
//   getExerciseById(String id)           — return single exercise by id
//   getUnsyncedExercises()               — WHERE isSynced = 0
//   markExerciseSynced(String id)        — UPDATE isSynced = 1 WHERE id = ?
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - searchExercises must be fast — called on every keystroke in search field
//   - insertAllExercises should use a batch for performance
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
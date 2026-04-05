// ============================================================
// local_workout_service.dart
// All SQLite read/write operations for workouts and workout_exercises tables.
//
// Usage:
//   await LocalWorkoutService.instance.insertWorkout(workout);
//   final workouts = await LocalWorkoutService.instance.getAllWorkouts(userId);
//   await LocalWorkoutService.instance.deleteWorkout(id);
//
// Methods to implement:
//   insertWorkout(WorkoutModel)                    — insert one workout row
//   getAllWorkouts(String userId)                   — return all workouts for user
//   getWorkoutById(String id)                      — return single workout
//   updateWorkout(WorkoutModel)                    — update existing workout row
//   deleteWorkout(String id)                       — delete workout by id
//   getUnsyncedWorkouts()                          — WHERE isSynced = 0
//   markWorkoutSynced(String id)                   — UPDATE isSynced = 1
//
//   insertWorkoutExercise(WorkoutExerciseModel)    — insert one workout_exercise row
//   getExercisesForWorkout(String workoutId)       — return all exercises for workout
//                                                    ordered by orderIndex ASC
//   updateWorkoutExercise(WorkoutExerciseModel)    — update existing row
//   deleteWorkoutExercise(String id)               — delete by id
//   getUnsyncedWorkoutExercises()                  — WHERE isSynced = 0
//   markWorkoutExerciseSynced(String id)           — UPDATE isSynced = 1
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getExercisesForWorkout must ORDER BY orderIndex ASC
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
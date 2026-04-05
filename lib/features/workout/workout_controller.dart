// ============================================================
// workout_controller.dart
// Brain for all workout, session, and exercise search logic.
// The largest controller in the app.
//
// Usage:
//   final controller = WorkoutController();
//   await controller.loadWorkouts(userId);
//   await controller.saveWorkout(workout, exercises);
//   await controller.startSession(workoutId, userId);
//   await controller.logSet(sessionId, exerciseId, setNumber, reps, weight);
//   await controller.finishSession(session, logs);
//   final results = await controller.searchExercises('bench');
//
// State to expose:
//   bool isLoading                      — true during async operations
//   List<WorkoutModel> workouts         — all workouts for current user
//   List<ExerciseModel> searchResults   — current exercise search results
//   WorkoutSessionModel? activeSession  — currently running session or null
//
// Methods to implement:
//   loadWorkouts(String userId)                          — load all workouts from SQLite
//   saveWorkout(WorkoutModel, List<WorkoutExerciseModel>)— insert workout + exercises,
//                                                          call sync after save
//   deleteWorkout(String id)                             — delete from SQLite + sync
//   startSession(String workoutId, String userId)        — create WorkoutSessionModel,
//                                                          insert to SQLite, set as active
//   logSet(sessionId, exerciseId, setNumber, reps,       — create SessionLogModel,
//          weight)                                         insert to SQLite
//   finishSession(WorkoutSessionModel,                   — calculate totalVolume,
//                 List<SessionLogModel>)                   totalDuration, caloriesBurned,
//                                                          update session in SQLite,
//                                                          award 100 XP via activity service,
//                                                          call sync
//   searchExercises(String query)                        — calls local_exercise_service
//                                                          LIKE search, updates searchResults
//   loadAllExercises()                                   — load full exercise list
//   seedExercisesIfNeeded()                              — check if exercises table is empty,
//                                                          if so fetch from Firestore and
//                                                          bulk insert to SQLite
//
// Rules:
//   - Always call sync_service.syncAll() after every save/delete
//   - finishSession must use Helpers.totalVolume() and Helpers.caloriesBurned()
//   - searchExercises called on every keystroke — keep it fast
//   - No Flutter UI imports except material.dart for BuildContext if needed
// ============================================================
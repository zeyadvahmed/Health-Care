// ============================================================
// remote_workout_service.dart
// Firestore push methods for workouts, workout exercises, sessions, and logs.
//
// Usage:
//   await RemoteWorkoutService.instance.pushWorkout(workout);
//   await RemoteWorkoutService.instance.pushSession(session);
//   await RemoteWorkoutService.instance.deleteWorkout(id);
//
// Methods to implement:
//   pushWorkout(WorkoutModel)                  — write workout to Firestore
//                                                collection: 'workouts'
//   pushWorkoutExercise(WorkoutExerciseModel)  — write to 'workout_exercises'
//   deleteWorkout(String id)                   — delete workout doc from Firestore
//   pushSession(WorkoutSessionModel)           — write to 'workout_sessions'
//   pushSessionLog(SessionLogModel)            — write to 'session_logs'
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
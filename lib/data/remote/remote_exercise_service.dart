// ============================================================
// remote_exercise_service.dart
// Firestore operations for the exercises collection.
//
// Usage:
//   await RemoteExerciseService.instance.pushExercise(exercise);
//   final exercises = await RemoteExerciseService.instance.fetchAllExercises();
//
// Methods to implement:
//   pushExercise(ExerciseModel)       — write one exercise to Firestore
//                                       collection: 'exercises', docId: exercise.id
//   fetchAllExercises()               — fetch all exercises from Firestore
//                                       called once on first launch to seed SQLite
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
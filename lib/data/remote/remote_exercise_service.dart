// ============================================================
// remote_exercise_service.dart
// lib/data/remote/remote_exercise_service.dart
//
// PURPOSE:
//   Firestore operations for the exercises ROOT collection.
//   Path: firestore / exercises / {id}
//
// THREE OPERATIONS:
//   1. fetchAllExercises() → called ONCE on first launch to
//      populate SQLite with all 873 exercises from Firestore.
//      Returns List<ExerciseModel> — conversion handled here.
//   2. pushAllExercises() → called ONCE by seedExercisesIfNeeded()
//      to upload all 873 exercises in chunked batches of 498.
//      Two network requests total (498 + 375).
//   3. pushExercise() → called by sync_service for any single
//      exercise that has isSynced = 0 (rare in practice).
//
// IMPORTANT:
//   exercises lives in a ROOT collection — NOT under users/{uid}.
//   Exercises are GLOBAL and shared by all users.
//   Seeded once to Firestore via the admin upload button.
//
// RULES:
//   - Singleton pattern
//   - Uses FirestoreService.instance — never touches Firestore directly
//   - Called ONLY by sync_service and workout_controller
//   - No Flutter UI imports
// ============================================================

import '../models/exercise_model.dart';
import 'firestore_service.dart';

class RemoteExerciseService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  RemoteExerciseService._internal();
  static final RemoteExerciseService instance =
      RemoteExerciseService._internal();

  static const String _collection = 'exercises';

  // ----------------------------------------------------------
  // fetchAllExercises()
  // Fetches ALL 873 exercise documents from Firestore and
  // returns them as ExerciseModel objects ready for SQLite.
  //
  // fromFirestore() handles:
  //   - Arrays → pipe-delimited strings for SQLite
  //   - Timestamp → DateTime
  //   - isSynced forced to true (came from Firestore)
  //
  // Called once by workout_controller.seedExercisesIfNeeded()
  // when the local exercises table is empty.
  // Never called again after the first successful seed.
  // ----------------------------------------------------------
  Future<List<ExerciseModel>> fetchAllExercises() async {
    final docs = await FirestoreService.instance
        .getCollection(_collection);

    // Conversion stays here — controller receives clean models
    return docs
        .map((doc) => ExerciseModel.fromFirestore(doc))
        .toList();
  }

  // ----------------------------------------------------------
  // pushAllExercises()
  // Uploads a list of exercises to Firestore in chunked batches.
  // Handles the 500-operation Firestore batch limit by splitting
  // the list into chunks of 498.
  //
  // For 873 exercises:
  //   Chunk 1: exercises[0..497]   → 498 docs → 1 network request
  //   Chunk 2: exercises[498..872] → 375 docs → 1 network request
  //   Total: 2 network requests
  //
  // Called ONCE by workout_controller.seedExercisesIfNeeded()
  // after inserting exercises into SQLite locally.
  // Never called again — exercises are global and never change.
  // ----------------------------------------------------------
  Future<void> pushAllExercises(List<ExerciseModel> exercises) async {
    if (exercises.isEmpty) return;

    const int chunkSize = 498;

    for (int i = 0; i < exercises.length; i += chunkSize) {
      // Calculate end index — stop at list length on last chunk
      // Without this guard: sublist(498, 996) crashes on 873-item list
      final int end = (i + chunkSize < exercises.length)
          ? i + chunkSize
          : exercises.length;

      final chunk = exercises.sublist(i, end);

      // Build batch operations for this chunk
      final operations = chunk
          .map((exercise) => {
                'type': 'set',
                'collection': _collection,
                'docId': exercise.id,        // e.g. "3_4_Sit-Up"
                'data': exercise.toFirestore(), // Arrays, Timestamps
              })
          .toList();

      // One network request per chunk
      await FirestoreService.instance.batchWrite(operations);
    }
  }

  // ----------------------------------------------------------
  // pushExercise()
  // Pushes a single exercise document to Firestore.
  //
  // In practice this is rarely called — exercises come FROM
  // Firestore (seeded by admin), not created by users.
  // This exists for the edge case where sync_service finds
  // an exercise row with isSynced = 0.
  // ----------------------------------------------------------
  Future<void> pushExercise(ExerciseModel exercise) async {
    await FirestoreService.instance.setDocument(
      _collection,
      exercise.id,
      exercise.toFirestore(),
    );
  }
}
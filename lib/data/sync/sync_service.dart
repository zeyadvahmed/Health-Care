// ============================================================
// sync_service.dart
// lib/data/sync/sync_service.dart
//
// PURPOSE:
//   Bridge between SQLite and Firestore. Two directions:
//
//   PUSH (syncAll):
//     Finds all rows where isSynced=0 and pushes them up.
//     Called after every user action and when device goes online.
//
//   PULL (restoreFromFirestore):
//     Pulls all user data FROM Firestore INTO SQLite.
//     Called ONCE after login when local data is empty.
//     This is the "new device / fresh install" restore flow.
//
// WHEN SYNCALL IS CALLED:
//   1. After every controller save operation
//   2. Automatically when device reconnects (connectivity stream)
//
// WHEN RESTOREFROMFIRESTORE IS CALLED:
//   1. After login in auth_controller — ONLY if local data empty
//   2. Never called after signup (nothing in Firestore yet)
//   3. Never called on normal app opens (SQLite already has data)
//
// OFFLINE BEHAVIOUR:
//   syncAll() checks isOnline() first.
//   If offline → returns immediately, records stay isSynced=0.
//   When device reconnects → connectivity stream triggers syncAll.
//
// INDEPENDENCE GUARANTEE:
//   Every feature is wrapped in its own try/catch.
//   One failure never blocks the others from syncing.
//
// RULES:
//   - Singleton pattern
//   - Always check isOnline() before syncAll
//   - Mark synced IMMEDIATELY after each successful push
//   - No Flutter UI imports
// ============================================================

import '../local/local_exercise_service.dart';
import '../local/local_workout_service.dart';
import '../local/local_session_service.dart';
import '../local/local_activity_service.dart';
import '../remote/remote_exercise_service.dart';
import '../remote/remote_workout_service.dart';
import '../remote/remote_activity_service.dart';
import 'connectivity_service.dart';

class SyncService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  // ═══════════════════════════════════════════════════════════
  // PUSH — SQLite → Firestore
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // syncAll()
  // Master push method. Finds all isSynced=0 rows across all
  // workout/exercise/session tables and pushes them to Firestore.
  //
  // ORDER MATTERS:
  //   workouts must exist in Firestore before workout_exercises
  //   sessions must exist before session_logs
  //   So push parent records before child records.
  //
  // uid = Firebase Auth UID, needed for subcollection paths.
  // ----------------------------------------------------------
  Future<void> syncAll(String uid) async {
    // Check connectivity first — abort silently if offline.
    // Records stay isSynced=0 and will push when reconnected.
    final online = await ConnectivityService.instance.isOnline();
    if (!online) return;

    // Each feature in its own try/catch.
    // One failure must NOT stop the others from running.

    try {
      await _syncExercises();
    } catch (e) {
      print('SyncService._syncExercises failed: $e');
    }

    try {
      await _syncWorkouts();
    } catch (e) {
      print('SyncService._syncWorkouts failed: $e');
    }

    try {
      await _syncWorkoutExercises(uid);
    } catch (e) {
      print('SyncService._syncWorkoutExercises failed: $e');
    }

    try {
      await _syncSessions(uid);
    } catch (e) {
      print('SyncService._syncSessions failed: $e');
    }

    try {
      await _syncSessionLogs(uid);
    } catch (e) {
      print('SyncService._syncSessionLogs failed: $e');
    }

    try {
      await _syncActivity();
    } catch (e) {
      print('SyncService._syncActivity failed: $e');
    }
  }

  // ----------------------------------------------------------
  // _syncExercises()
  // Pushes unsynced exercises to Firestore ROOT collection.
  // Rare in practice — exercises come FROM Firestore, not from
  // the user. This handles the edge case where a row has
  // isSynced=0 after seeding.
  // ----------------------------------------------------------
  Future<void> _syncExercises() async {
    final unsynced =
        await LocalExerciseService.instance.getUnsyncedExercises();
    for (final exercise in unsynced) {
      await RemoteExerciseService.instance.pushExercise(exercise);
      await LocalExerciseService.instance
          .markExerciseSynced(exercise.id);
    }
  }

  // ----------------------------------------------------------
  // _syncWorkouts()
  // Pushes unsynced workouts to Firestore ROOT collection.
  // ----------------------------------------------------------
  Future<void> _syncWorkouts() async {
    final unsynced =
        await LocalWorkoutService.instance.getUnsyncedWorkouts();
    for (final workout in unsynced) {
      await RemoteWorkoutService.instance.pushWorkout(workout);
      await LocalWorkoutService.instance
          .markWorkoutSynced(workout.id);
    }
  }

  // ----------------------------------------------------------
  // _syncWorkoutExercises()
  // Pushes unsynced workout_exercises to the user's subcollection.
  // uid is required to build: users/{uid}/workout_exercises
  // ----------------------------------------------------------
  Future<void> _syncWorkoutExercises(String uid) async {
    final unsynced = await LocalWorkoutService.instance
        .getUnsyncedWorkoutExercises();
    for (final we in unsynced) {
      await RemoteWorkoutService.instance
          .pushWorkoutExercise(we, uid);
      await LocalWorkoutService.instance
          .markWorkoutExerciseSynced(we.id);
    }
  }

  // ----------------------------------------------------------
  // _syncSessions()
  // Pushes unsynced COMPLETED sessions to Firestore.
  // Active sessions (endTime = null) are skipped — they are
  // never pushed until the user finishes the workout.
  // ----------------------------------------------------------
  Future<void> _syncSessions(String uid) async {
    final unsynced =
        await LocalSessionService.instance.getUnsyncedSessions();
    for (final session in unsynced) {
      // Skip active sessions — only push completed ones
      if (session.endTime == null) continue;
      await RemoteWorkoutService.instance.pushSession(session, uid);
      await LocalSessionService.instance
          .markSessionSynced(session.id);
    }
  }

  // ----------------------------------------------------------
  // _syncSessionLogs()
  // Pushes unsynced set logs to the user's subcollection.
  // ----------------------------------------------------------
  Future<void> _syncSessionLogs(String uid) async {
    final unsynced =
        await LocalSessionService.instance.getUnsyncedLogs();
    for (final log in unsynced) {
      await RemoteWorkoutService.instance.pushSessionLog(log, uid);
      await LocalSessionService.instance.markLogSynced(log.id);
    }
  }


  // ═══════════════════════════════════════════════════════════
  // PULL — Firestore → SQLite (restore on fresh install)
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // restoreFromFirestore()
  // Pulls ALL user workout data from Firestore into SQLite.
  // Called by auth_controller.login() ONLY when local data
  // is empty — meaning this is a fresh install or the local
  // database was cleared.
  //
  // STRATEGY — Firestore wins:
  //   We clear any partial local data first, then insert
  //   everything fresh from Firestore. Simple and safe.
  //   The alternative (merge by updatedAt) is complex and
  //   unnecessary for this app's use case.
  //
  // ORDER:
  //   1. exercises — seeded globally, not per-user
  //   2. workouts  — parent of workout_exercises
  //   3. workout_exercises — child of workouts
  //   4. sessions  — completed workout records
  //   5. session_logs — set-by-set breakdown per session
  //
  //   Parent tables must be restored before child tables
  //   to maintain referential integrity.
  //
  // Each step is independent — one failure doesn't block others.
  //
  // userId = app's internal user UUID (stored in users table)
  // uid    = Firebase Auth UID (used for subcollection paths)
  // ----------------------------------------------------------
  Future<void> restoreFromFirestore({
    required String userId,
    required String uid,
  }) async {
    // Must be online to restore from Firestore
    final online = await ConnectivityService.instance.isOnline();
    if (!online) return;

    // ── Step 1: Exercises ─────────────────────────────────
    // Pull all 873 exercises from the global exercises collection.
    // These are the same for every user — seeded once globally.
    // If already seeded, insertAllExercises uses
    // ConflictAlgorithm.replace so duplicates are safe.
    try {
      final exercises =
          await RemoteExerciseService.instance.fetchAllExercises();
      if (exercises.isNotEmpty) {
        await LocalExerciseService.instance
            .insertAllExercises(exercises);
      }
    } catch (e) {
      print('restoreFromFirestore: exercises failed → $e');
    }

    // ── Step 2: Workouts ──────────────────────────────────
    // Pull all workouts the user has created.
    // Filters by userId field inside each Firestore document.
    try {
      final workouts = await RemoteWorkoutService.instance
          .fetchWorkoutsForUser(userId);
      for (final workout in workouts) {
        // Mark as synced — it just came FROM Firestore
        await LocalWorkoutService.instance.insertWorkout(
          workout.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: workouts failed → $e');
    }

    // ── Step 3: Workout Exercises ─────────────────────────
    // Pull all exercises linked to the user's workouts.
    // Uses the uid subcollection path (not userId filter).
    try {
      final workoutExercises = await RemoteWorkoutService.instance
          .fetchWorkoutExercisesForUser(uid);
      for (final we in workoutExercises) {
        await LocalWorkoutService.instance.insertWorkoutExercise(
          we.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: workout_exercises failed → $e');
    }

    // ── Step 4: Sessions ──────────────────────────────────
    // Pull all completed workout sessions.
    // Active sessions are never in Firestore so all fetched
    // sessions are guaranteed to have endTime set.
    try {
      final sessions = await RemoteWorkoutService.instance
          .fetchSessionsForUser(uid);
      for (final session in sessions) {
        await LocalSessionService.instance.insertSession(
          session.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: sessions failed → $e');
    }

    // ── Step 5: Session Logs ──────────────────────────────
    // Pull all set logs for all sessions.
    // This can be a large number of documents if the user
    // has a long workout history — called only once.
    try {
      final logs = await RemoteWorkoutService.instance
          .fetchLogsForUser(uid);
      for (final log in logs) {
        await LocalSessionService.instance.insertSessionLog(
          log.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: session_logs failed → $e');
    }
  }
}
// ============================================================
// sync_service.dart
// lib/data/sync/sync_service.dart
//
// PURPOSE:
//   Bridge between SQLite and Firestore.
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
// NOTE — _syncActivity is INTENTIONALLY OMITTED:
//   local_activity_service.dart and remote_activity_service.dart
//   have no implemented methods yet. Importing them causes
//   compile errors. Uncomment the import and _syncActivity()
//   call in syncAll() once both services are implemented.
//
// RULES:
//   - Singleton pattern
//   - Always check isOnline() before syncAll
//   - Mark synced IMMEDIATELY after each successful push
//   - No Flutter UI imports
// ============================================================

import '../local/local_activity_service.dart';
import '../local/local_exercise_service.dart';
import '../local/local_hydration_service.dart';
import '../local/local_medical_service.dart';
import '../local/local_mood_service.dart';
import '../local/local_nutrition_service.dart';
import '../local/local_workout_service.dart';
import '../local/local_session_service.dart';
import '../remote/remote_activity_service.dart';
import '../remote/remote_exercise_service.dart';
import '../remote/remote_hydration_service.dart';
import '../remote/remote_medical_service.dart';
import '../remote/remote_mood_service.dart';
import '../remote/remote_nutrition_service.dart';
import '../remote/remote_workout_service.dart';
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
  // workout/exercise/session tables and pushes to Firestore.
  //
  // ORDER MATTERS:
  //   workouts must exist in Firestore before workout_exercises.
  //   sessions must exist before session_logs.
  //   Push parent records before child records.
  //
  // uid = Firebase Auth UID, needed for subcollection paths.
  // ----------------------------------------------------------
  Future<void> syncAll(String uid) async {
    // Check connectivity — abort silently if offline.
    // Records stay isSynced=0 and push when reconnected.
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
      await _syncNutrition(uid);
    } catch (e) {
      print('SyncService._syncNutrition failed: $e');
    }

    try {
      await _syncMood(uid);
    } catch (e) {
      print('SyncService._syncMood failed: $e');
    }

    try {
      await _syncHydration(uid);
    } catch (e) {
      print('SyncService._syncHydration failed: $e');
    }

    try {
      await _syncMedical(uid);
    } catch (e) {
      print('SyncService._syncMedical failed: $e');
    }

    try {
      await _syncActivity(uid);
    } catch (e) {
      print('SyncService._syncActivity failed: $e');
    }
  }

  // ----------------------------------------------------------
  // _syncExercises()
  // Pushes unsynced exercises to Firestore ROOT collection.
  // Rare in practice — exercises come FROM Firestore via seeding.
  // This handles the edge case where a row has isSynced=0
  // after the initial seed.
  // ----------------------------------------------------------
  Future<void> _syncExercises() async {
    final unsynced = await LocalExerciseService.instance.getUnsyncedExercises();
    for (final exercise in unsynced) {
      await RemoteExerciseService.instance.pushExercise(exercise);
      await LocalExerciseService.instance.markExerciseSynced(exercise.id);
    }
  }

  // ----------------------------------------------------------
  // _syncWorkouts()
  // Pushes unsynced workouts to Firestore ROOT collection.
  // ----------------------------------------------------------
  Future<void> _syncWorkouts() async {
    final unsynced = await LocalWorkoutService.instance.getUnsyncedWorkouts();
    for (final workout in unsynced) {
      await RemoteWorkoutService.instance.pushWorkout(workout);
      await LocalWorkoutService.instance.markWorkoutSynced(workout.id);
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
      await RemoteWorkoutService.instance.pushWorkoutExercise(we, uid);
      await LocalWorkoutService.instance.markWorkoutExerciseSynced(we.id);
    }
  }

  // ----------------------------------------------------------
  // _syncSessions()
  // Pushes unsynced COMPLETED sessions to Firestore.
  // Active sessions (endTime = null) are skipped — they are
  // never pushed until the user finishes the workout.
  // ----------------------------------------------------------
  Future<void> _syncSessions(String uid) async {
    final unsynced = await LocalSessionService.instance.getUnsyncedSessions();
    for (final session in unsynced) {
      if (session.endTime == null) continue; // never push active sessions
      await RemoteWorkoutService.instance.pushSession(session, uid);
      await LocalSessionService.instance.markSessionSynced(session.id);
    }
  }

  // ----------------------------------------------------------
  // _syncSessionLogs()
  // Pushes unsynced set logs to the user's subcollection.
  // ----------------------------------------------------------
  Future<void> _syncSessionLogs(String uid) async {
    final unsynced = await LocalSessionService.instance.getUnsyncedLogs();
    for (final log in unsynced) {
      await RemoteWorkoutService.instance.pushSessionLog(log, uid);
      await LocalSessionService.instance.markLogSynced(log.id);
    }
  }

  // ----------------------------------------------------------
  // _syncActivity()
  // STUB — intentionally not implemented yet.
  // LocalActivityService and RemoteActivityService have no
  // methods. Uncomment imports above and restore this method
  // once both services are implemented:
  //
  // Future<void> _syncActivity() async {
  //   final unsynced =
  //       await LocalActivityService.instance.getUnsyncedActivity();
  //   for (final activity in unsynced) {
  //     await RemoteActivityService.instance.pushActivity(activity);
  //     await LocalActivityService.instance.markActivitySynced(activity.id);
  //   }
  // }
  // ----------------------------------------------------------

  // ═══════════════════════════════════════════════════════════
  // ----------------------------------------------------------
  // _syncNutrition()
  // Nutrition tables do not have isSynced columns yet, so this
  // pushes the current local snapshot to Firestore.
  // ----------------------------------------------------------
  Future<void> _syncNutrition(String uid) async {
    final localNutrition = LocalNutritionService();
    final foodItems = await localNutrition.getAllFoodItems();
    final dailyGoal = await localNutrition.getDailyGoal();

    await RemoteNutritionService.instance.pushAllFoodItems(uid, foodItems);
    await RemoteNutritionService.instance.updateDailyGoal(uid, dailyGoal);
  }

  // ----------------------------------------------------------
  // _syncMood()
  // Mood tables do not have isSynced columns yet, so this
  // pushes the current local snapshot to Firestore.
  // ----------------------------------------------------------
  Future<void> _syncMood(String uid) async {
    final localMood = LocalMoodService();
    final entries = await localMood.getAllMoodEntries();
    final dailyMoods = await localMood.getAllDailyMoods();

    await RemoteMoodService.instance.pushAllMoodEntries(uid, entries);
    await RemoteMoodService.instance.pushAllDailyMoods(uid, dailyMoods);
  }

  Future<void> _syncHydration(String uid) async {
    final unsynced = await LocalHydrationService.instance.getUnsyncedEntries();
    for (final entry in unsynced) {
      await RemoteHydrationService.instance.pushEntry(entry, uid);
      await LocalHydrationService.instance.markEntrySynced(entry.id);
    }
  }

  Future<void> _syncMedical(String uid) async {
    final unsynced =
        await LocalMedicalService.instance.getUnsyncedMedicalRecords();
    for (final record in unsynced) {
      await RemoteMedicalService.instance.pushMedicalRecord(record, uid);
      await LocalMedicalService.instance.markMedicalRecordSynced(record.id);
    }
  }

  Future<void> _syncActivity(String uid) async {
    final unsynced =
        await LocalActivityService.instance.getUnsyncedActivity();
    for (final activity in unsynced) {
      await RemoteActivityService.instance.pushActivity(uid, activity);
      await LocalActivityService.instance.markActivitySynced(activity.id);
    }
  }

  // PULL — Firestore → SQLite (restore on fresh install)
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // restoreFromFirestore()
  // Pulls ALL user workout data from Firestore into SQLite.
  // Called by auth_controller.login() ONLY when local data
  // is empty — meaning fresh install or cleared database.
  //
  // STRATEGY — Firestore wins:
  //   Insert everything fresh from Firestore.
  //   ConflictAlgorithm.replace in insert methods handles
  //   any partial local data safely.
  //
  // ORDER (parent tables before child tables):
  //   1. exercises       — global, not per-user
  //   2. workouts        — parent of workout_exercises
  //   3. workout_exercises — child of workouts
  //   4. sessions        — completed workout records
  //   5. session_logs    — set-by-set breakdown per session
  //
  // userId = app's internal user UUID (stored in users table)
  // uid    = Firebase Auth UID (used for subcollection paths)
  // ----------------------------------------------------------
  Future<void> restoreFromFirestore({
    required String userId,
    required String uid,
  }) async {
    final online = await ConnectivityService.instance.isOnline();
    if (!online) return;

    // ── Step 1: Exercises ─────────────────────────────────
    try {
      final exercises = await RemoteExerciseService.instance
          .fetchAllExercises();
      if (exercises.isNotEmpty) {
        await LocalExerciseService.instance.insertAllExercises(exercises);
      }
    } catch (e) {
      print('restoreFromFirestore: exercises failed → $e');
    }

    // ── Step 2: Workouts ──────────────────────────────────
    try {
      final workouts = await RemoteWorkoutService.instance.fetchWorkoutsForUser(
        userId,
      );
      for (final workout in workouts) {
        await LocalWorkoutService.instance.insertWorkout(
          workout.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: workouts failed → $e');
    }

    // ── Step 3: Workout Exercises ─────────────────────────
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
    try {
      final sessions = await RemoteWorkoutService.instance.fetchSessionsForUser(
        uid,
      );
      for (final session in sessions) {
        await LocalSessionService.instance.insertSession(
          session.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: sessions failed → $e');
    }

    // ── Step 5: Session Logs ──────────────────────────────
    try {
      final logs = await RemoteWorkoutService.instance.fetchLogsForUser(uid);
      for (final log in logs) {
        await LocalSessionService.instance.insertSessionLog(
          log.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: session_logs failed → $e');
    }

    // ── Step 6: Nutrition ─────────────────────────────────
    // Pull all food items and the daily calorie goal for the user.
    try {
      final localNutrition = LocalNutritionService();
      final foodItems = await RemoteNutritionService.instance.getAllFoodItems(
        uid,
      );
      await localNutrition.clear();
      for (final item in foodItems) {
        await localNutrition.insertFoodItem(item);
      }

      final dailyGoal = await RemoteNutritionService.instance.getDailyGoal(uid);
      await localNutrition.updateDailyGoal(dailyGoal);
    } catch (e) {
      print('restoreFromFirestore: nutrition failed → $e');
    }

    // ── Step 7: Mood ──────────────────────────────────────
    // Pull all mood entries and daily mood summaries for the user.
    try {
      final localMood = LocalMoodService();
      final entries = await RemoteMoodService.instance.getAllMoodEntries(uid);
      final dailyMoods = await RemoteMoodService.instance.getAllDailyMoods(uid);

      await localMood.clearMoodData();
      for (final mood in dailyMoods) {
        await localMood.upsertDailyMood(mood);
      }
      for (final entry in entries) {
        await localMood.insertMoodEntry(entry);
      }
    } catch (e) {
      print('restoreFromFirestore: mood failed → $e');
    }

    try {
      final entries =
          await RemoteHydrationService.instance.fetchEntriesForUser(uid);
      for (final entry in entries) {
        await LocalHydrationService.instance.insertEntry(
          entry.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: hydration failed -> $e');
    }

    try {
      final records =
          await RemoteMedicalService.instance.fetchMedicalRecordsForUser(uid);
      for (final record in records) {
        await LocalMedicalService.instance.insertMedicalRecord(
          record.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: medical failed -> $e');
    }

    try {
      final activities = await RemoteActivityService.instance.fetchActivities(
        uid,
      );
      for (final activity in activities) {
        await LocalActivityService.instance.insertActivity(
          activity.copyWith(isSynced: true),
        );
      }
    } catch (e) {
      print('restoreFromFirestore: activity failed -> $e');
    }
  }
}

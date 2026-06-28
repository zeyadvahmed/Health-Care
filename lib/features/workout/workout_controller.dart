// ============================================================
// workout_controller.dart
// lib/features/workout/workout_controller.dart
//
// Cubit that owns all workout business logic.
//
// STATE FLOW:
//   loadWorkouts  → Loading → Loaded | Error
//   saveWorkout   → Loading → Loaded | Error
//   deleteWorkout → Loading → Loaded | Error
//   startSession  → SessionActive
//   finishSession → Loading → Loaded | Error
//   searchExercises / loadAllExercises → SearchResults
//
// ACTIVITY / XP:
//   LocalActivityService has no implemented methods yet.
//   _awardXp() is stubbed — restore when service is implemented.
//
// SYNC:
//   syncAll() is always fire-and-forget wrapped in its own
//   try/catch so a network failure NEVER corrupts local state.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/workout_model.dart';
import '../../data/models/workout_exercise_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/session_log_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/local/local_workout_service.dart';
import '../../data/local/local_session_service.dart';
import '../../data/local/local_exercise_service.dart';
import '../../data/remote/remote_exercise_service.dart';
import '../../data/sync/sync_service.dart';
import 'workout_state.dart';

// Imports below are commented out until services are implemented:
// import '../../data/models/activity_model.dart';
// import '../../data/local/local_activity_service.dart';

class WorkoutController extends Cubit<WorkoutState> {
  final _uuid = Uuid();

  // In-memory cache — avoids re-querying SQLite after every
  // save/delete. Always kept in sync with the database.
  List<WorkoutModel> _workouts = [];

  WorkoutController() : super(WorkoutInitial());

  // ═══════════════════════════════════════════════════════════
  // WORKOUT LOADING
  // ═══════════════════════════════════════════════════════════

  /// Loads all workouts (predefined + user's own) from SQLite.
  /// Called once in WorkoutsListScreen.initState().
  Future<void> loadWorkouts(String userId) async {
    emit(WorkoutLoading());
    try {
      _workouts = await LocalWorkoutService.instance.getAllWorkouts(userId);
      emit(WorkoutLoaded(workouts: _workouts));
    } catch (e) {
      emit(WorkoutError(message: 'Could not load workouts. Please try again.'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // WORKOUT CRUD
  // ═══════════════════════════════════════════════════════════

  /// Saves a workout + its exercises to SQLite then syncs.
  ///
  /// Works for both CREATE and EDIT:
  ///   CREATE → insert workout row + all exercise rows
  ///   EDIT   → replace workout row, delete ALL old exercise rows
  ///            first, then re-insert the current list.
  ///
  /// ORDER IS CRITICAL:
  ///   1. insertWorkout (replace if exists)
  ///   2. deleteExercisesForWorkout (wipe old rows)
  ///   3. insertWorkoutExercise × N (insert current list)
  ///   Wrong order = exercises wiped after insertion.
  Future<void> saveWorkout(
    WorkoutModel workout,
    List<WorkoutExerciseModel> exercises,
    String uid,
  ) async {
    emit(WorkoutLoading());
    try {
      // Step 1 — insert/replace the workout row.
      await LocalWorkoutService.instance.insertWorkout(workout);

      // Step 2 — delete ALL old exercise rows BEFORE inserting.
      // On CREATE this is a no-op (nothing to delete).
      // On EDIT this removes any exercises the user removed.
      await LocalWorkoutService.instance.deleteExercisesForWorkout(workout.id);

      // Step 3 — insert the current exercise list with correct order.
      for (int i = 0; i < exercises.length; i++) {
        final we = exercises[i].copyWith(workoutId: workout.id, orderIndex: i);
        await LocalWorkoutService.instance.insertWorkoutExercise(we);
      }

      // Update in-memory cache without re-querying SQLite.
      final existingIndex = _workouts.indexWhere((w) => w.id == workout.id);
      if (existingIndex >= 0) {
        _workouts[existingIndex] = workout; // edit: replace in place
      } else {
        _workouts.insert(0, workout); // create: prepend
      }

      emit(WorkoutLoaded(workouts: _workouts));

      // Sync is fire-and-forget — network failure must never
      // affect the local success state already emitted above.
      _syncSilently(uid);
    } catch (e) {
      emit(WorkoutError(message: 'Could not save workout. Please try again.'));
    }
  }

  /// Deletes a single exercise row from workout_exercises by its id.
  /// Used by WorkoutOverviewScreen when the user removes one exercise.
  /// Does NOT delete the parent workout row.
  /// Does NOT emit state — screen updates its own local list via setState.
  Future<void> deleteSingleExercise(String exerciseRowId, String uid) async {
    await LocalWorkoutService.instance.deleteWorkoutExercise(exerciseRowId);
    _syncSilently(uid);
  }

  /// Deletes a workout and all its linked exercises.
  /// Child rows deleted BEFORE parent — avoids orphan rows.
  Future<void> deleteWorkout(String workoutId, String uid) async {
    emit(WorkoutLoading());
    try {
      // Delete children first, then parent.
      await LocalWorkoutService.instance.deleteExercisesForWorkout(workoutId);
      await LocalWorkoutService.instance.deleteWorkout(workoutId);

      _workouts.removeWhere((w) => w.id == workoutId);
      emit(WorkoutLoaded(workouts: _workouts));

      // Fire-and-forget sync.
      _syncSilently(uid);
    } catch (e) {
      emit(WorkoutError(message: 'Could not delete workout.'));
    }
  }

  /// Returns exercises for a workout ordered by orderIndex ASC.
  /// Does NOT emit state — screen awaits this in initState.
  Future<List<WorkoutExerciseModel>> getExercisesForWorkout(
    String workoutId,
  ) async {
    return LocalWorkoutService.instance.getExercisesForWorkout(workoutId);
  }

  /// Returns a single workout by id, or null if not found.
  /// Used by WorkoutOverviewScreen to refresh after edit.
  Future<WorkoutModel?> getWorkoutById(String id) async {
    return LocalWorkoutService.instance.getWorkoutById(id);
  }

  // ═══════════════════════════════════════════════════════════
  // EXERCISE NAME RESOLUTION
  // ═══════════════════════════════════════════════════════════

  /// Maps exerciseId → ExerciseModel for display in tiles.
  ///
  /// CRITICAL: Call ONLY in initState — never in build() or
  /// inside a ListView.builder().
  ///
  /// Returns a Map so screens can look up name + muscles once
  /// and store the result in local state.
  Future<Map<String, ExerciseModel>> resolveExerciseNames(
    List<WorkoutExerciseModel> exercises,
  ) async {
    final Map<String, ExerciseModel> map = {};
    for (final we in exercises) {
      if (map.containsKey(we.exerciseId)) continue;
      final exercise = await LocalExerciseService.instance.getExerciseById(
        we.exerciseId,
      );
      if (exercise != null) map[we.exerciseId] = exercise;
    }
    return map;
  }

  /// Returns a single ExerciseModel by id, or null if not found.
  Future<ExerciseModel?> getExerciseById(String exerciseId) async {
    return LocalExerciseService.instance.getExerciseById(exerciseId);
  }

  // ═══════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Creates an active session row in SQLite (endTime = null).
  /// Emits WorkoutSessionActive so ActiveSessionScreen can
  /// listen and navigate with the session object.
  Future<WorkoutSessionModel> startSession(
    String workoutId,
    String userId,
  ) async {
    final now = DateTime.now();
    final session = WorkoutSessionModel(
      id: _uuid.v4(),
      workoutId: workoutId,
      userId: userId,
      startTime: now,
      endTime: null,
      totalVolume: 0,
      totalDuration: 0,
      caloriesBurned: 0,
      updatedAt: now,
      isSynced: false,
    );
    await LocalSessionService.instance.insertSession(session);
    emit(WorkoutSessionActive(activeSession: session));
    return session;
  }

  /// Records one completed set in SQLite.
  /// Does NOT emit state — ActiveSessionScreen manages its own
  /// checked-set list with setState for instant responsiveness.
  Future<SessionLogModel> logSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    double? weight,
  }) async {
    final now = DateTime.now();
    final log = SessionLogModel(
      id: _uuid.v4(),
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      isCompleted: true,
      timestamp: now,
      updatedAt: now,
      isSynced: false,
    );
    await LocalSessionService.instance.insertSessionLog(log);
    return log;
  }

  /// Completes a session: calculates totals, persists to SQLite,
  /// emits WorkoutLoaded, then syncs in background.
  ///
  /// Returns the completed session so WorkoutSummaryScreen can
  /// display duration/volume/calories without another DB call.
  Future<WorkoutSessionModel> finishSession(
    WorkoutSessionModel session,
    List<SessionLogModel> logs,
    String userId,
    String uid,
  ) async {
    emit(WorkoutLoading());
    try {
      final endTime = DateTime.now();

      // totalVolume = sum of reps × weight for weighted sets.
      double totalVolume = 0;
      for (final log in logs) {
        if (log.isCompleted && log.weight != null) {
          totalVolume += log.reps * log.weight!;
        }
      }

      final totalDuration = endTime.difference(session.startTime).inSeconds;

      // ~5 kcal/min is a standard rough estimate for resistance training.
      final caloriesBurned = (totalDuration / 60 * 5).round();

      final completedSession = session.copyWith(
        endTime: endTime,
        totalVolume: totalVolume,
        totalDuration: totalDuration,
        caloriesBurned: caloriesBurned,
        updatedAt: endTime,
        isSynced: false,
      );

      await LocalSessionService.instance.updateSession(completedSession);

      // XP award stubbed — LocalActivityService not implemented yet.
      // Restore when implemented:
      // await _awardXp(userId);

      emit(WorkoutLoaded(workouts: _workouts, activeSession: completedSession));

      // Fire-and-forget sync.
      _syncSilently(uid);

      return completedSession;
    } catch (e) {
      emit(
        WorkoutError(message: 'Could not finish session. Please try again.'),
      );
      rethrow; // rethrow so caller can handle if needed
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EXERCISE SEARCH
  // ═══════════════════════════════════════════════════════════

  /// LIKE search on exercise names. Called on every keystroke.
  /// Empty query → emits empty results without hitting SQLite.
  Future<void> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      emit(WorkoutSearchResults(results: []));
      return;
    }
    try {
      final results = await LocalExerciseService.instance.searchExercises(
        query.trim(),
      );
      emit(WorkoutSearchResults(results: results));
    } catch (e) {
      emit(WorkoutSearchResults(results: []));
    }
  }

  /// Loads all exercises from SQLite.
  /// Called when ExerciseSearchScreen opens with empty query.
  Future<void> loadAllExercises() async {
    try {
      final all = await LocalExerciseService.instance.getAllExercises();
      emit(WorkoutSearchResults(results: all));
    } catch (e) {
      emit(WorkoutSearchResults(results: []));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SEEDING
  // ═══════════════════════════════════════════════════════════

  /// Seeds 873 exercises from Firestore into SQLite on first launch.
  /// Called once from HomeScreen.initState().
  /// Silent on error — app still works, just no exercise search.
  Future<void> seedExercisesIfNeeded() async {
    try {
      final existing = await LocalExerciseService.instance.getAllExercises();
      if (existing.isNotEmpty) return;

      final models = await RemoteExerciseService.instance.fetchAllExercises();
      if (models.isEmpty) return;

      // Fetch all exercise documents from Firestore
      // This is the only Firestore READ in normal app flow
      // Bulk insert into SQLite using batch for performance
      await LocalExerciseService.instance.insertAllExercises(models);
      debugPrint('WorkoutController: seeded ${models.length} exercises');
    } catch (e) {
      debugPrint('WorkoutController: seeding failed → $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════

  /// Returns all completed sessions ordered newest first.
  /// Does NOT emit state — screen awaits in initState.
  Future<List<WorkoutSessionModel>> getSessionsForUser(String userId) async {
    return LocalSessionService.instance.getSessionsForUser(userId);
  }

  /// Returns all set logs for one session ordered by setNumber ASC.
  Future<List<SessionLogModel>> getLogsForSession(String sessionId) async {
    return LocalSessionService.instance.getLogsForSession(sessionId);
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Fires syncAll in the background.
  /// A network error is logged but NEVER propagates to the UI —
  /// local state has already been committed and emitted.
  void _syncSilently(String uid) {
    SyncService.instance.syncAll(uid).catchError((e) {
      debugPrint('WorkoutController: background sync failed → $e');
    });
  }

  // Stub — restore when LocalActivityService is implemented:
  //
  // Future<void> _awardXp(String userId) async {
  //   final current =
  //       await LocalActivityService.instance.getActivityForUser(userId);
  //   final now = DateTime.now();
  //   if (current == null) {
  //     final newActivity = ActivityModel(
  //       id:            const Uuid().v4(),
  //       userId:        userId,
  //       totalXp:       100,
  //       currentLevel:  0,
  //       xpToNextLevel: 400,
  //       updatedAt:     now,
  //       isSynced:      false,
  //     );
  //     await LocalActivityService.instance.insertActivity(newActivity);
  //   } else {
  //     final newXp     = current.totalXp + 100;
  //     final newLevel  = newXp ~/ 500;
  //     final updated = current.copyWith(
  //       totalXp:       newXp,
  //       currentLevel:  newLevel,
  //       xpToNextLevel: ((newLevel + 1) * 500) - newXp,
  //       updatedAt:     now,
  //       isSynced:      false,
  //     );
  //     await LocalActivityService.instance.updateActivity(updated);
  //   }
  // }
}

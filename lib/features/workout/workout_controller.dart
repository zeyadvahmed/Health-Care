// ============================================================
// workout_controller.dart
// lib/features/workout/workout_controller.dart
//
// PURPOSE:
//   The brain for all workout, session, exercise search,
//   and XP/level logic. The largest controller in the app.
//
// WHAT IT MANAGES:
//   - Loading and displaying workouts from SQLite
//   - Creating, editing, and deleting workouts
//   - Starting an active workout session
//   - Logging each set as user checks checkboxes
//   - Finishing a session: calculating totals + awarding XP
//   - Searching exercises by name (called on every keystroke)
//   - Seeding the exercise library on first launch
//
// STATE EXPOSED TO SCREENS:
//   isLoading      → show LoadingWidget while fetching data
//   errorMessage   → show error snackbar if not null
//   workouts       → list displayed in workout_list_screen
//   searchResults  → list displayed in search field dropdown
//   activeSession  → current in-progress session or null
//
// XP FORMULA:
//   +100 XP per completed session (flat, no multipliers)
//   currentLevel  = totalXp ~/ 500
//   xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
//
// EXTENDS CHANGENOTIFIER:
//   Screens call addListener to rebuild when state changes.
//   Always call notifyListeners() after changing any state.
//
// RULES:
//   - Always call SyncService.instance.syncAll(uid) after saves
//   - Set isLoading=true before async, false in finally block
//   - Never import screens — navigate via passed BuildContext
// ============================================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/workout_exercise_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/session_log_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/local/local_workout_service.dart';
import '../../data/local/local_session_service.dart';
import '../../data/local/local_exercise_service.dart';
import '../../data/local/local_activity_service.dart';
import '../../data/remote/remote_exercise_service.dart';
import '../../data/sync/sync_service.dart';

class WorkoutController extends ChangeNotifier {

  // ── Exposed state ────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  List<WorkoutModel> workouts = [];
  List<ExerciseModel> searchResults = [];
  WorkoutSessionModel? activeSession;

  // UUID generator — creates unique ids for new records
  final _uuid = const Uuid();

  // ═══════════════════════════════════════════════════════════
  // WORKOUT LOADING
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // loadWorkouts()
  // Fetches all workouts for this user from SQLite.
  // Stores them in the 'workouts' list and calls notifyListeners
  // so workout_list_screen rebuilds with the new data.
  // Called in workout_list_screen's initState().
  // ----------------------------------------------------------
  Future<void> loadWorkouts(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // tell screen: start showing LoadingWidget

    try {
      workouts =
          await LocalWorkoutService.instance.getAllWorkouts(userId);
    } catch (e) {
      errorMessage = 'Could not load workouts. Please try again.';
    } finally {
      // Always set isLoading=false — even if an error occurred
      isLoading = false;
      notifyListeners(); // tell screen: stop showing LoadingWidget
    }
  }

  // ═══════════════════════════════════════════════════════════
  // WORKOUT CRUD
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // saveWorkout()
  // Saves a new workout with its exercises to SQLite.
  // Order of operations:
  //   1. Insert the workout row
  //   2. Insert each workout_exercise row with orderIndex = i
  //   3. Add workout to local list (so UI updates immediately)
  //   4. Call syncAll to push to Firestore if online
  // ----------------------------------------------------------
  Future<void> saveWorkout(
    WorkoutModel workout,
    List<WorkoutExerciseModel> exercises,
    String uid, // Firebase uid for sync subcollection paths
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Insert the workout template
      await LocalWorkoutService.instance.insertWorkout(workout);

      // 2. Insert each exercise with its position in the workout
      for (int i = 0; i < exercises.length; i++) {
        // Assign workoutId and orderIndex before inserting
        final we = exercises[i].copyWith(
          workoutId: workout.id,
          orderIndex: i, // position 0, 1, 2... determines display order
        );
        await LocalWorkoutService.instance.insertWorkoutExercise(we);
      }

      // 3. Add to local list so list screen updates without reload
      workouts.insert(0, workout);

      // 4. Push to Firestore in background (non-blocking)
      await SyncService.instance.syncAll(uid);
    } catch (e) {
      errorMessage = 'Could not save workout. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // deleteWorkout()
  // Deletes a workout and ALL its associated exercises.
  // Order matters:
  //   1. Delete workout_exercises rows first (foreign key child)
  //   2. Then delete the workout row (parent)
  //   3. Remove from local list for immediate UI update
  //   4. Sync to Firestore
  // ----------------------------------------------------------
  Future<void> deleteWorkout(String workoutId, String uid) async {
    try {
      // 1. Delete child rows first
      await LocalWorkoutService.instance
          .deleteExercisesForWorkout(workoutId);

      // 2. Delete the parent row
      await LocalWorkoutService.instance.deleteWorkout(workoutId);

      // 3. Remove from in-memory list → list screen rebuilds
      workouts.removeWhere((w) => w.id == workoutId);
      notifyListeners();

      // 4. Sync the deletion to Firestore
      await SyncService.instance.syncAll(uid);
    } catch (e) {
      errorMessage = 'Could not delete workout.';
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // getExercisesForWorkout()
  // Returns all exercises for a workout from SQLite.
  // Already ordered by orderIndex ASC from the service.
  // Called by workout_overview_screen and workout_session_screen.
  // ----------------------------------------------------------
  Future<List<WorkoutExerciseModel>> getExercisesForWorkout(
      String workoutId) async {
    return await LocalWorkoutService.instance
        .getExercisesForWorkout(workoutId);
  }

  // ═══════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // startSession()
  // Creates a new WorkoutSessionModel with:
  //   - a fresh UUID as id
  //   - endTime = null (session is active)
  //   - all totals = 0 (filled in when session finishes)
  // Inserts it to SQLite and stores as activeSession.
  // Returns the session so the screen can pass it forward.
  // ----------------------------------------------------------
  Future<WorkoutSessionModel> startSession(
      String workoutId, String userId) async {
    final now = DateTime.now();

    final session = WorkoutSessionModel(
      id: _uuid.v4(),   // random UUID
      workoutId: workoutId,
      userId: userId,
      startTime: now,
      endTime: null,    // null = session is currently active
      totalVolume: 0,
      totalDuration: 0,
      caloriesBurned: 0,
      updatedAt: now,
      isSynced: false,  // will be pushed to Firestore after finish
    );

    await LocalSessionService.instance.insertSession(session);

    // Store as activeSession so other parts of app can check
    activeSession = session;
    notifyListeners();

    return session;
  }

  // ----------------------------------------------------------
  // logSet()
  // Records one completed set during an active session.
  // Called each time the user checks a set checkbox.
  // Creates a SessionLogModel and inserts it to SQLite.
  // Returns the log so it can be added to the screen's local list.
  //
  // Parameters:
  //   sessionId  → the active session's id
  //   exerciseId → which exercise this set belongs to
  //   setNumber  → 1-based set number (Set 1, Set 2, Set 3...)
  //   reps       → how many reps the user did
  //   weight     → weight in kg, null for bodyweight exercises
  // ----------------------------------------------------------
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
      weight: weight,    // null for bodyweight
      isCompleted: true, // this set is done
      timestamp: now,
      updatedAt: now,
      isSynced: false,
    );

    await LocalSessionService.instance.insertSessionLog(log);
    return log;
  }

  // ----------------------------------------------------------
  // finishSession()
  // Completes an active workout session. Steps:
  //   1. Calculate totalVolume from all set logs
  //   2. Calculate totalDuration from startTime to now
  //   3. Estimate caloriesBurned (5 kcal per minute)
  //   4. Update session in SQLite with all final values
  //   5. Award +100 XP to user via _awardXp()
  //   6. Clear activeSession
  //   7. Call syncAll to push everything to Firestore
  //
  // Returns the completed session for workout_summary_screen.
  // ----------------------------------------------------------
  Future<WorkoutSessionModel> finishSession(
    WorkoutSessionModel session,
    List<SessionLogModel> logs,
    String userId,
    String uid, // Firebase uid for sync
  ) async {
    final endTime = DateTime.now();

    // Step 1: Calculate total volume
    // totalVolume = sum of (reps × weight) for all completed sets
    // Sets with null weight (bodyweight) contribute 0 to volume
    double totalVolume = 0;
    for (final log in logs) {
      if (log.weight != null && log.isCompleted) {
        totalVolume += log.reps * log.weight!;
      }
    }

    // Step 2: Calculate total duration in seconds
    final totalDuration =
        endTime.difference(session.startTime).inSeconds;

    // Step 3: Estimate calories burned
    // Rough estimate: 5 kcal per minute of exercise
    final caloriesBurned = (totalDuration / 60 * 5).round();

    // Step 4: Build the completed session with all final values
    final completedSession = session.copyWith(
      endTime: endTime,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      caloriesBurned: caloriesBurned,
      updatedAt: endTime,
      isSynced: false, // will be pushed to Firestore by syncAll
    );

    // Persist the completed session to SQLite
    await LocalSessionService.instance.updateSession(completedSession);

    // Step 5: Award +100 XP and update level
    await _awardXp(userId);

    // Step 6: Clear active session state
    activeSession = null;
    notifyListeners();

    // Step 7: Push everything to Firestore in background
    await SyncService.instance.syncAll(uid);

    return completedSession;
  }

  // ----------------------------------------------------------
  // _awardXp()
  // Private method — called only by finishSession().
  // Awards +100 XP and recalculates level.
  //
  // First time (no activity row exists):
  //   → Create a new activity row with totalXp=100
  //
  // Subsequent times (activity row already exists):
  //   → Add 100 to existing totalXp
  //   → Recalculate currentLevel and xpToNextLevel
  //
  // Level formula:
  //   currentLevel  = totalXp ~/ 500   (~/ = integer division)
  //   xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
  //
  // Examples:
  //   totalXp=0    → level=0, toNext=500
  //   totalXp=100  → level=0, toNext=400
  //   totalXp=500  → level=1, toNext=500
  //   totalXp=600  → level=1, toNext=400
  //   totalXp=1000 → level=2, toNext=500
  // ----------------------------------------------------------
  Future<void> _awardXp(String userId) async {
    final existing =
        await LocalActivityService.instance.getActivityForUser(userId);
    final now = DateTime.now();

    if (existing == null) {
      // FIRST WORKOUT EVER — create the activity row
      const int newTotalXp = 100;
      final int level = newTotalXp ~/ 500; // = 0
      final int xpToNext = ((level + 1) * 500) - newTotalXp; // = 400

      await LocalActivityService.instance.insertActivity(
        ActivityModel(
          id: _uuid.v4(),
          userId: userId,
          totalXp: newTotalXp,
          currentLevel: level,
          xpToNextLevel: xpToNext,
          updatedAt: now,
          isSynced: false,
        ),
      );
    } else {
      // SUBSEQUENT WORKOUT — update existing activity row
      final int newTotalXp = existing.totalXp + 100;
      final int level = newTotalXp ~/ 500;
      final int xpToNext = ((level + 1) * 500) - newTotalXp;

      await LocalActivityService.instance.updateActivity(
        existing.copyWith(
          totalXp: newTotalXp,
          currentLevel: level,
          xpToNextLevel: xpToNext,
          updatedAt: now,
          isSynced: false,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EXERCISE SEARCH
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // searchExercises()
  // Searches exercise names in SQLite using LIKE query.
  // Updates searchResults and notifies listeners.
  // Called on EVERY KEYSTROKE in ExerciseSearchField and
  // exercise_search_screen — must stay very fast.
  //
  // Empty query → clears results (don't show stale results)
  // ----------------------------------------------------------
  Future<void> searchExercises(String query) async {
    if (query.trim().isEmpty) {
      // Clear results when user deletes all text
      searchResults = [];
      notifyListeners();
      return;
    }

    try {
      searchResults = await LocalExerciseService.instance
          .searchExercises(query.trim());
      notifyListeners(); // rebuild dropdown in ExerciseSearchField
    } catch (e) {
      searchResults = [];
      notifyListeners();
    }
  }

  // ----------------------------------------------------------
  // loadAllExercises()
  // Loads all exercises into searchResults.
  // Called by exercise_search_screen on init when there is
  // no search query yet — shows all 873 exercises by default.
  // ----------------------------------------------------------
  Future<void> loadAllExercises() async {
    try {
      searchResults =
          await LocalExerciseService.instance.getAllExercises();
      notifyListeners();
    } catch (e) {
      searchResults = [];
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EXERCISE SEEDING (FIRST LAUNCH)
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // seedExercisesIfNeeded()
  // Checks if the exercises table in SQLite is empty.
  // If empty → fetches all 873 exercises from Firestore and
  //            bulk inserts them into SQLite.
  // If not empty → returns immediately (already seeded).
  //
  // This runs ONCE on first app launch after login.
  // It never runs again on the same device after that.
  // Call this from the home_screen initState after login.
  //
  // If seeding fails (no internet on first launch), it fails
  // silently — the app still works, just search is empty.
  // On next launch when internet is available, it will seed.
  // ----------------------------------------------------------
  Future<void> seedExercisesIfNeeded() async {
    try {
      // Check if exercises already exist in SQLite
      final existing =
          await LocalExerciseService.instance.getAllExercises();

      if (existing.isNotEmpty) {
        // Already seeded — skip entirely
        return;
      }

      // Fetch all exercise documents from Firestore
      // This is the only Firestore READ in normal app flow
      final remoteMaps =
          await RemoteExerciseService.instance.fetchAllExercises();

      if (remoteMaps.isEmpty) return;

      // Convert raw Firestore maps to ExerciseModel objects
      final models = remoteMaps
          .map((map) => ExerciseModel.fromFirestore(map))
          .toList();

      // Bulk insert into SQLite using batch for performance
      await LocalExerciseService.instance.insertAllExercises(models);

      print('WorkoutController: seeded ${models.length} exercises');
    } catch (e) {
      // Fail silently — don't crash the app if seeding fails
      // User can still use the app, search will just be empty
      print('WorkoutController: seeding failed → $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // getSessionsForUser()
  // Returns all completed sessions for workout_history_screen.
  // Already ordered newest first from the service.
  // ----------------------------------------------------------
  Future<List<WorkoutSessionModel>> getSessionsForUser(
      String userId) async {
    return await LocalSessionService.instance
        .getSessionsForUser(userId);
  }

  // ----------------------------------------------------------
  // getLogsForSession()
  // Returns all set logs for one session.
  // Used by workout_history_screen when user expands a card.
  // ----------------------------------------------------------
  Future<List<SessionLogModel>> getLogsForSession(
      String sessionId) async {
    return await LocalSessionService.instance
        .getLogsForSession(sessionId);
  }
}
// ============================================================
// workout_state.dart
// lib/features/workout/workout_state.dart
//
// All states emitted by WorkoutController (Cubit).
//
// STATE USAGE MAP — which screen reacts to which state:
//
//   WorkoutInitial
//     → WorkoutsListScreen builder: shows loading spinner
//
//   WorkoutLoading
//     → WorkoutsListScreen builder:  shows loading spinner
//     → CreateWorkoutScreen builder: shows saving overlay
//     → WorkoutOverviewScreen builder: shows busy overlay
//     → ActiveSessionScreen builder: shows finishing overlay
//     → ExerciseSearchScreen builder: shows spinner
//
//   WorkoutLoaded
//     → WorkoutsListScreen builder:       renders workout lists
//     → CreateWorkoutScreen listener:     pops screen (save done)
//     → WorkoutOverviewScreen listener:   (not used directly)
//     → ActiveSessionScreen listener:     navigates to Summary
//       — only when activeSession != null (finishSession path)
//
//   WorkoutSearchResults
//     → ExerciseSearchScreen builder: renders exercise list
//
//   WorkoutSessionActive
//     → WorkoutOverviewScreen listener: navigates to ActiveSession
//
//   WorkoutError
//     → All screens listener: shows error snackbar
// ============================================================

import '../../data/models/workout_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/workout_session_model.dart';

// ── Base class ─────────────────────────────────────────────
abstract class WorkoutState {}

// ── WorkoutInitial ─────────────────────────────────────────
// Emitted by WorkoutController() constructor.
// WorkoutsListScreen shows a spinner until loadWorkouts() fires.
class WorkoutInitial extends WorkoutState {}

// ── WorkoutLoading ─────────────────────────────────────────
// Emitted at the start of every async operation:
//   loadWorkouts, saveWorkout, deleteWorkout, finishSession.
// Screens show a loading indicator while this is active.
class WorkoutLoading extends WorkoutState {}

// ── WorkoutLoaded ──────────────────────────────────────────
// Emitted after any successful write or load completes.
//
// workouts
//   Always present. Full list of predefined + user workouts.
//   Used by WorkoutsListScreen to rebuild the two lists.
//
// activeSession
//   Non-null ONLY after finishSession() completes.
//   ActiveSessionScreen listener checks activeSession != null
//   before navigating to WorkoutSummaryScreen.
//   Null in all other WorkoutLoaded emissions.
class WorkoutLoaded extends WorkoutState {
  final List<WorkoutModel> workouts;
  final WorkoutSessionModel? activeSession;

  WorkoutLoaded({required this.workouts, this.activeSession});
}

// ── WorkoutSearchResults ───────────────────────────────────
// Emitted by searchExercises() and loadAllExercises().
// ExerciseSearchScreen rebuilds its list on every emission.
//
// results
//   Matched exercises. Empty list when:
//     - query is blank (loadAllExercises failed silently)
//     - search returned no matches
//     - SQLite threw an error (silent fallback to [])
class WorkoutSearchResults extends WorkoutState {
  final List<ExerciseModel> results;

  WorkoutSearchResults({required this.results});
}

// ── WorkoutSessionActive ───────────────────────────────────
// Emitted by startSession() after the session row is inserted
// into SQLite with endTime = null (session is live).
//
// WorkoutOverviewScreen listener catches this and navigates
// to ActiveSessionScreen, passing activeSession as a param.
//
// activeSession
//   The newly created session with startTime set and
//   endTime = null. Passed to ActiveSessionScreen.
class WorkoutSessionActive extends WorkoutState {
  final WorkoutSessionModel activeSession;

  WorkoutSessionActive({required this.activeSession});
}

// ── WorkoutError ───────────────────────────────────────────
// Emitted when any operation fails inside a try/catch.
// Every screen's BlocListener shows a snackbar with message.
//
// message
//   Human-readable string shown in the error snackbar.
//   Never expose raw exception text to the user.
class WorkoutError extends WorkoutState {
  final String message;

  WorkoutError({required this.message});
}

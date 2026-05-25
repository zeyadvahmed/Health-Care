// ============================================================
// workout_state.dart
// lib/features/workout/workout_state.dart
//
// PURPOSE:
//   Defines every possible state the WorkoutCubit can be in.
//   The cubit emits one of these states and BlocBuilder
//   rebuilds the UI whenever a new state arrives.
//
// HOW STATES WORK IN THIS APP:
//   WorkoutInitial     → app just started, nothing loaded yet
//   WorkoutLoading     → async operation in progress
//   WorkoutLoaded      → workouts fetched, ready to display
//   WorkoutSearching   → exercise search results updated
//   WorkoutSessionActive → a session is currently running
//   WorkoutError       → something went wrong, show message
//
// RULE:
//   Every state holds ALL the data the UI needs to render.
//   Screens never store data locally — they read it from state.
// ============================================================

import '../../data/models/workout_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/exercise_model.dart';

// Base class — every state extends this
abstract class WorkoutState {}

// ── Initial ────────────────────────────────────────────────
// Emitted once when the cubit is first created.
// workout_list_screen shows nothing until LoadWorkouts is called.
class WorkoutInitial extends WorkoutState {}

// ── Loading ────────────────────────────────────────────────
// Emitted at the START of any async operation.
// Screens show LoadingWidget when this state is active.
class WorkoutLoading extends WorkoutState {}

// ── Loaded ─────────────────────────────────────────────────
// Emitted after workouts are successfully fetched from SQLite.
// workout_list_screen builds its list from this state.
class WorkoutLoaded extends WorkoutState {
  final List<WorkoutModel> workouts;
  final WorkoutSessionModel? activeSession;

  WorkoutLoaded({
    required this.workouts,
    this.activeSession,
  });
}

// ── Search Results ─────────────────────────────────────────
// Emitted every time searchExercises() or loadAllExercises()
// completes. exercise_search_screen rebuilds its list.
class WorkoutSearchResults extends WorkoutState {
  final List<ExerciseModel> results;

  WorkoutSearchResults({required this.results});
}

// ── Session Active ─────────────────────────────────────────
// Emitted when a session starts and when sets are logged.
// active_session_screen reads activeSession from this state.
class WorkoutSessionActive extends WorkoutState {
  final WorkoutSessionModel activeSession;

  WorkoutSessionActive({required this.activeSession});
}

// ── Error ──────────────────────────────────────────────────
// Emitted when any operation fails.
// Screens show an error snackbar when this state arrives.
// message is shown to the user — keep it human-readable.
class WorkoutError extends WorkoutState {
  final String message;

  WorkoutError({required this.message});
}
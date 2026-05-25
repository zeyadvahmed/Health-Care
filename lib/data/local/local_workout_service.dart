// ============================================================
// local_workout_service.dart
// lib/data/local/local_workout_service.dart
//
// PURPOSE:
//   All SQLite CRUD for the workouts and workout_exercises tables.
//
// TWO TABLES MANAGED HERE:
//   workouts          → workout templates (predefined + user-created)
//   workout_exercises → exercises inside each workout with
//                       sets/reps/weight/rest/order settings
//
// getAllWorkouts() RETURNS BOTH:
//   - isPredefined = 1 → seeded workouts (same for every user)
//   - isPredefined = 0 AND userId = ? → user-created workouts
//   Using WHERE userId = ? ALONE would miss all predefined workouts
//   and the predefined section would always be empty.
//
// IMPORTANT ORDER RULE:
//   getExercisesForWorkout() MUST order by orderIndex ASC.
//   Without this, exercises display in random insertion order.
//
// DELETE ORDER:
//   Always call deleteExercisesForWorkout(workoutId) BEFORE
//   deleteWorkout(id). This avoids orphaned exercise rows.
//
// RULES:
//   - Singleton pattern
//   - Always get DB via: DatabaseHelper.instance.database
//   - No Flutter UI imports
// ============================================================

import 'package:sqflite/sqflite.dart';
import '../models/workout_model.dart';
import '../models/workout_exercise_model.dart';
import 'database_helper.dart';

class LocalWorkoutService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  LocalWorkoutService._internal();
  static final LocalWorkoutService instance =
      LocalWorkoutService._internal();

  // ═══════════════════════════════════════════════════════════
  // WORKOUTS TABLE
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // insertWorkout()
  // Inserts or replaces a workout row.
  // ConflictAlgorithm.replace handles both CREATE and EDIT:
  //   - New workout → inserts fresh row
  //   - Edited workout with same id → replaces existing row
  // ----------------------------------------------------------
  Future<void> insertWorkout(WorkoutModel workout) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'workouts',
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // getAllWorkouts()
  // Returns BOTH predefined workouts AND user-created workouts.
  //
  // WHY THE OR CLAUSE:
  //   Predefined workouts are seeded with a system userId (not
  //   the current user's id). Using WHERE userId = ? alone
  //   would never return predefined workouts — the predefined
  //   section in WorkoutsListScreen would always be empty.
  //
  // ORDER:
  //   isPredefined DESC → predefined workouts appear first
  //   createdAt DESC    → newest user workouts appear at top
  //
  // WorkoutsListScreen then splits into two lists:
  //   predefined = workouts.where((w) => w.isPredefined)
  //   mine       = workouts.where((w) => !w.isPredefined)
  // ----------------------------------------------------------
  Future<List<WorkoutModel>> getAllWorkouts(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workouts',
      where: 'userId = ? OR isPredefined = 1',
      whereArgs: [userId],
      orderBy: 'isPredefined DESC, createdAt DESC',
    );
    return maps.map((map) => WorkoutModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // getWorkoutById()
  // Returns a single workout by id, or null if not found.
  // ----------------------------------------------------------
  Future<WorkoutModel?> getWorkoutById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WorkoutModel.fromMap(maps.first);
  }

  // ----------------------------------------------------------
  // updateWorkout()
  // Updates all fields of an existing workout row by id.
  // ----------------------------------------------------------
  Future<void> updateWorkout(WorkoutModel workout) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  // ----------------------------------------------------------
  // deleteWorkout()
  // Deletes a workout row by id.
  // WARNING: Always call deleteExercisesForWorkout() FIRST to
  // avoid leaving orphaned workout_exercise rows behind.
  // ----------------------------------------------------------
  Future<void> deleteWorkout(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // getUnsyncedWorkouts()
  // Returns all workouts where isSynced = 0.
  // Called by sync_service when pushing to Firestore.
  // ----------------------------------------------------------
  Future<List<WorkoutModel>> getUnsyncedWorkouts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workouts',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => WorkoutModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // markWorkoutSynced()
  // Sets isSynced = 1 for the given workout id.
  // Called by sync_service after successful Firestore push.
  // ----------------------------------------------------------
  Future<void> markWorkoutSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workouts',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WORKOUT_EXERCISES TABLE
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // insertWorkoutExercise()
  // Inserts one exercise-in-workout row.
  // ----------------------------------------------------------
  Future<void> insertWorkoutExercise(WorkoutExerciseModel we) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'workout_exercises',
      we.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // getExercisesForWorkout()
  // Returns all exercises for a workout.
  // CRITICAL: ORDER BY orderIndex ASC ensures exercises display
  // in the same order the user arranged them.
  // ----------------------------------------------------------
  Future<List<WorkoutExerciseModel>> getExercisesForWorkout(
      String workoutId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workout_exercises',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'orderIndex ASC',
    );
    return maps.map((map) => WorkoutExerciseModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // updateWorkoutExercise()
  // Updates an existing exercise row — used when user edits
  // sets, reps, or weight in the workout editor.
  // ----------------------------------------------------------
  Future<void> updateWorkoutExercise(WorkoutExerciseModel we) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workout_exercises',
      we.toMap(),
      where: 'id = ?',
      whereArgs: [we.id],
    );
  }

  // ----------------------------------------------------------
  // deleteWorkoutExercise()
  // Deletes a single exercise from a workout by its row id.
  // ----------------------------------------------------------
  Future<void> deleteWorkoutExercise(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------------------------------------
  // deleteExercisesForWorkout()
  // Deletes ALL exercise rows for a given workoutId.
  //
  // Called in TWO situations:
  //   1. Before deleteWorkout() — cleans up child rows first
  //   2. Before re-inserting in saveWorkout() edit mode —
  //      removes exercises the user deleted from the list
  //
  // Without this, removed exercises stay as orphan rows and
  // appear again the next time the workout is opened.
  // ----------------------------------------------------------
  Future<void> deleteExercisesForWorkout(String workoutId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'workout_exercises',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
  }

  // ----------------------------------------------------------
  // getUnsyncedWorkoutExercises()
  // Returns all workout_exercise rows where isSynced = 0.
  // ----------------------------------------------------------
  Future<List<WorkoutExerciseModel>> getUnsyncedWorkoutExercises() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workout_exercises',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => WorkoutExerciseModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // markWorkoutExerciseSynced()
  // Sets isSynced = 1 for the given workout_exercise id.
  // ----------------------------------------------------------
  Future<void> markWorkoutExerciseSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workout_exercises',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
// ============================================================
// local_workout_service.dart
// lib/data/local/local_workout_service.dart
//
// PURPOSE:
//   All SQLite CRUD for the workouts and workout_exercises tables.
//
// TWO TABLES MANAGED HERE:
//   workouts          → workout templates (the plan itself)
//   workout_exercises → exercises inside each workout with
//                       sets/reps/weight/rest/order settings
//
// IMPORTANT ORDER RULE:
//   getExercisesForWorkout() MUST order by orderIndex ASC.
//   Without this, exercises display in random insertion order.
//
// DELETE ORDER:
//   Always delete workout_exercises BEFORE deleting the workout.
//   Call deleteExercisesForWorkout(workoutId) first, then
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
  // Inserts a new workout row. ConflictAlgorithm.replace
  // means editing an existing workout with the same id will
  // update it instead of throwing an error.
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
  // Returns all workouts for a specific user.
  // Ordered by createdAt DESC → newest workouts first in list.
  // ----------------------------------------------------------
  Future<List<WorkoutModel>> getAllWorkouts(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workouts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
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
  // Updates all fields of an existing workout row.
  // Uses the workout's id to find the right row.
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
  // WARNING: Always call deleteExercisesForWorkout() first
  // to avoid leaving orphaned workout_exercise rows behind.
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
      orderBy: 'orderIndex ASC', // CRITICAL: preserves exercise order
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
  // Used when user removes one exercise from a workout.
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
  // ALWAYS call this before deleteWorkout() to avoid leaving
  // orphaned rows in workout_exercises table.
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
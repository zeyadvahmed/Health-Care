// ============================================================
// local_exercise_service.dart
// lib/data/local/local_exercise_service.dart
//
// PURPOSE:
//   All SQLite read/write operations for the exercises table.
//   This is the global exercise library (873 exercises).
//
// HOW EXERCISES GET INTO SQLITE:
//   1. On first launch, workout_controller.seedExercisesIfNeeded()
//      is called after login.
//   2. It checks if exercises table is empty.
//   3. If empty: fetches all from Firestore exercises collection
//      via remote_exercise_service.fetchAllExercises().
//   4. Calls insertAllExercises() to bulk insert all 873 rows.
//   5. Never runs again after the first successful seed.
//
// SEARCH PERFORMANCE:
//   searchExercises() is called on every single keystroke in
//   ExerciseSearchField and exercise_search_screen. It must
//   be fast. We cap results at 20 and use a simple LIKE query.
//
// RULES:
//   - Singleton pattern
//   - Always get DB via: DatabaseHelper.instance.database
//   - No Flutter UI imports — pure Dart + sqflite only
// ============================================================

import 'package:sqflite/sqflite.dart';
import '../models/exercise_model.dart';
import 'database_helper.dart';

class LocalExerciseService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  LocalExerciseService._internal();
  static final LocalExerciseService instance =
      LocalExerciseService._internal();

  // ----------------------------------------------------------
  // insertExercise()
  // Inserts a single exercise into SQLite.
  // ConflictAlgorithm.replace means if an exercise with the
  // same id already exists, it gets updated instead of
  // throwing an error.
  // ----------------------------------------------------------
  Future<void> insertExercise(ExerciseModel exercise) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // insertAllExercises()
  // Bulk inserts all 873 exercises using a SQLite batch.
  // A batch groups all inserts into a single transaction,
  // which is ~100x faster than calling insertExercise() 873 times.
  // 'noResult: true' skips collecting the row IDs — faster.
  // ----------------------------------------------------------
  Future<void> insertAllExercises(List<ExerciseModel> exercises) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();

    for (final exercise in exercises) {
      batch.insert(
        'exercises',
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // in case of duplicates, delete old and insert new.
      );
    }

    // noResult:true = don't collect the inserted row IDs
    // This is faster when we don't need the return values
    await batch.commit(noResult: true); // Executes all inserts in a single transaction.
  }

  // ----------------------------------------------------------
  // getAllExercises()
  // Returns every exercise from SQLite as a list.
  // Used by:
  //   - workout_controller.seedExercisesIfNeeded() to check
  //     if the table is empty before seeding
  //   - exercise_search_screen when query is empty (show all)
  // ----------------------------------------------------------
  Future<List<ExerciseModel>> getAllExercises() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('exercises');
    return maps.map((map) => ExerciseModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // searchExercises()
  // Searches exercises by name using SQL LIKE query.
  // '%query%' matches any name that CONTAINS the query string.
  // Example: query='bench' matches 'Bench Press', 'Dumbbell Bench'
  //
  // Capped at 20 results for UI performance.
  // Called on every single keystroke — must stay fast.
  // ----------------------------------------------------------
  Future<List<ExerciseModel>> searchExercises(String query) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'exercises',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 20, // cap results — called on every keystroke
    );
    return maps.map((map) => ExerciseModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // getExerciseById()
  // Returns a single exercise by its id.
  // Returns null if no exercise found with that id.
  // Used when building session logs or displaying exercise details.
  // ----------------------------------------------------------
  Future<ExerciseModel?> getExerciseById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ExerciseModel.fromMap(maps.first);
  }

  // ----------------------------------------------------------
  // getUnsyncedExercises()
  // Returns all exercises where isSynced = 0.
  // Called by sync_service._syncExercises() when device
  // comes back online to push unsynced rows to Firestore.
  // ----------------------------------------------------------
  Future<List<ExerciseModel>> getUnsyncedExercises() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'exercises',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => ExerciseModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // markExerciseSynced()
  // Sets isSynced = 1 for the given exercise id.
  // Called by sync_service immediately after successfully
  // pushing an exercise to Firestore.
  // ----------------------------------------------------------
  Future<void> markExerciseSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'exercises',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
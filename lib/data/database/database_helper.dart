// ============================================================
// database_helper.dart
// lib/data/local/database_helper.dart
//
// PURPOSE:
//   Singleton that opens and manages the SQLite database file
//   sparksteel.db. Creates all 12 tables on first launch.
//
// SCHEMA VERSIONS:
//   version 1 → initial schema (missing imageUrl on workouts)
//   version 2 → added imageUrl TEXT column to workouts table
//
// HOW IT WORKS:
//   - Uses singleton pattern so only ONE database connection
//     ever exists in the entire app lifetime
//   - The 'database' getter returns the open DB or opens it
//   - _onCreate() runs ONCE when the file is first created
//   - _onUpgrade() runs when version increases on existing installs
//
// RULES:
//   - Never instantiate this class directly
//   - Always use: DatabaseHelper.instance.database
//   - Never import Flutter widgets here — pure Dart + sqflite
//   - All id columns → TEXT PRIMARY KEY (UUID strings)
//   - All booleans → INTEGER 0 or 1
//   - All DateTimes → TEXT in ISO 8601 format
//   - Pipe-delimited TEXT for lists: "chest|shoulders"
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  // ----------------------------------------------------------
  // SINGLETON PATTERN
  // ----------------------------------------------------------
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  // ----------------------------------------------------------
  // database (getter)
  // ----------------------------------------------------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ----------------------------------------------------------
  // _initDB()
  // Opens the database at version 2.
  // Fresh installs → _onCreate runs (builds full schema).
  // Existing v1 installs → _onUpgrade runs (adds imageUrl).
  // ----------------------------------------------------------
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sparksteel.db');

    return await openDatabase(
      path,
      version: 2,               // bumped from 1 → 2
      onCreate: _onCreate,       // fresh install: build full schema
      onUpgrade: _onUpgrade,     // existing install: run migration
    );
  }

  // ----------------------------------------------------------
  // _onUpgrade()
  // Runs when the database version on device is LOWER than the
  // version passed to openDatabase().
  //
  // v1 → v2: adds imageUrl column to workouts table.
  //   ALTER TABLE is safe — existing rows get NULL for imageUrl,
  //   which matches the nullable imageUrl field in WorkoutModel.
  //
  // Always use if/else blocks per version step so upgrades from
  // any version reach the latest schema correctly.
  // ----------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add imageUrl column that was missing from v1 schema.
      // WorkoutModel.toMap() writes imageUrl and fromMap() reads it —
      // without this column every workout read/write crashes.
      await db.execute(
        'ALTER TABLE workouts ADD COLUMN imageUrl TEXT',
      );
    }
    // Future migrations:
    // if (oldVersion < 3) { ... }
  }

  // ----------------------------------------------------------
  // _onCreate()
  // Runs exactly ONCE on fresh install. Builds all 12 tables
  // at the latest schema version (v2 — includes imageUrl).
  // ----------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {

    // ── TABLE 1: users ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        uid TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        profileImageUrl TEXT,
        age INTEGER,
        weight REAL,
        height REAL,
        caloriesGoal INTEGER NOT NULL DEFAULT 2000,
        waterGoal INTEGER NOT NULL DEFAULT 2500,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 2: exercises ──────────────────────────────────
    // 873 rows seeded from Firestore on first launch.
    // primaryMuscles, secondaryMuscles, instructions →
    // pipe-delimited strings e.g. "chest|shoulders"
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT '',
        level TEXT NOT NULL DEFAULT '',
        equipment TEXT NOT NULL DEFAULT '',
        primaryMuscles TEXT NOT NULL DEFAULT '',
        secondaryMuscles TEXT NOT NULL DEFAULT '',
        instructions TEXT NOT NULL DEFAULT '',
        imageUrl TEXT NOT NULL DEFAULT '',
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 3: workouts ───────────────────────────────────
    // Workout templates. isPredefined 0=user-created, 1=seeded.
    // imageUrl is nullable — predefined workouts may have an
    // image URL; user-created workouts default to null.
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        difficulty TEXT NOT NULL DEFAULT 'beginner',
        durationMinutes INTEGER NOT NULL DEFAULT 30,
        isPredefined INTEGER NOT NULL DEFAULT 0,
        imageUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 4: workout_exercises ──────────────────────────
    // Junction: workout → exercises with user-chosen settings.
    // orderIndex controls display order (ORDER BY orderIndex ASC).
    await db.execute('''
      CREATE TABLE workout_exercises (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        sets INTEGER NOT NULL DEFAULT 3,
        reps INTEGER NOT NULL DEFAULT 10,
        weight REAL,
        restSeconds INTEGER NOT NULL DEFAULT 60,
        orderIndex INTEGER NOT NULL DEFAULT 0,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 5: workout_sessions ───────────────────────────
    // One row per workout attempt.
    // endTime = NULL while the session is still active.
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        userId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        totalVolume REAL NOT NULL DEFAULT 0,
        totalDuration INTEGER NOT NULL DEFAULT 0,
        caloriesBurned INTEGER NOT NULL DEFAULT 0,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 6: session_logs ───────────────────────────────
    // One row per completed set during a session.
    // setNumber is 1-based. weight = NULL for bodyweight.
    await db.execute('''
      CREATE TABLE session_logs (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        timestamp TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 7: nutrition_plans ────────────────────────────
    // One row per user per day.
    // date stored as 'yyyy-MM-dd' for WHERE date=? queries.
    await db.execute('''
      CREATE TABLE nutrition_plans (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        totalCalories INTEGER NOT NULL DEFAULT 0,
        totalProtein REAL NOT NULL DEFAULT 0,
        totalCarbs REAL NOT NULL DEFAULT 0,
        totalFats REAL NOT NULL DEFAULT 0,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 8: nutrition_meals ────────────────────────────
    // Individual food entries inside a nutrition plan.
    // mealType: breakfast | lunch | dinner | snack
    await db.execute('''
      CREATE TABLE nutrition_meals (
        id TEXT PRIMARY KEY,
        planId TEXT NOT NULL,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL DEFAULT 0,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fats REAL NOT NULL DEFAULT 0,
        mealType TEXT NOT NULL DEFAULT 'snack',
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 9: hydration_entries ──────────────────────────
    // One row per +250ml / +500ml tap.
    // dailyGoalMl stored per entry for historical accuracy.
    await db.execute('''
      CREATE TABLE hydration_entries (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        amountMl INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT '250ml',
        dailyGoalMl INTEGER NOT NULL DEFAULT 2500,
        timestamp TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 10: mood_entries ──────────────────────────────
    // mood: happy | calm | tired | stressed
    // note is nullable.
    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        mood TEXT NOT NULL,
        note TEXT,
        timestamp TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 11: medical_records ───────────────────────────
    // scheduleTimes pipe-delimited: "08:00|20:00"
    // endDate is NULL for open-ended medications.
    await db.execute('''
      CREATE TABLE medical_records (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'pill',
        dosage TEXT NOT NULL DEFAULT '',
        frequency TEXT NOT NULL DEFAULT 'once_daily',
        scheduleTimes TEXT NOT NULL DEFAULT '',
        startDate TEXT NOT NULL,
        endDate TEXT,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 12: activity ──────────────────────────────────
    // One row per user. Updated after every finished session.
    // Level formula (computed in controller):
    //   currentLevel  = totalXp ~/ 500
    //   xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
    await db.execute('''
      CREATE TABLE activity (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        totalXp INTEGER NOT NULL DEFAULT 0,
        currentLevel INTEGER NOT NULL DEFAULT 0,
        xpToNextLevel INTEGER NOT NULL DEFAULT 500,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
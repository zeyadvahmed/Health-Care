// ============================================================
// database_helper.dart
// lib/data/local/database_helper.dart
//
// PURPOSE:
//   Singleton that opens and manages the SQLite database file
//   sparksteel.db. Creates all 12 tables on first launch.
//
// HOW IT WORKS:
//   - Uses singleton pattern so only ONE database connection
//     ever exists in the entire app lifetime
//   - The 'database' getter returns the open DB or opens it
//   - _onCreate() runs ONCE when the file is first created
//   - After that _onCreate never runs again on the same device
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
  // _internal() is a private named constructor.
  // 'instance' is the one and only object of this class.
  // Every call to DatabaseHelper.instance returns the same object.
  // ----------------------------------------------------------
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // The actual database object — null until first access
  static Database? _database;

  // ----------------------------------------------------------
  // database (getter)
  // The entry point for every local service.
  // If database is already open → returns it immediately.
  // If not open yet → calls _initDB() to open it.
  // This is called like: await DatabaseHelper.instance.database
  // ----------------------------------------------------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ----------------------------------------------------------
  // _initDB()
  // Finds the correct path for the database file on device,
  // then opens it. 'version: 1' is the schema version.
  // 'onCreate' only runs when the file does not exist yet.
  // ----------------------------------------------------------
  Future<Database> _initDB() async {
    // getDatabasesPath() returns the device's documents directory
    final dbPath = await getDatabasesPath();
    // join() builds the full path: /data/user/.../sparksteel.db
    final path = join(dbPath, 'sparksteel.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // runs once on fresh install
    );
  }

  // ----------------------------------------------------------
  // _onCreate()
  // Runs exactly ONCE when the database file is first created.
  // Creates all 12 tables in the correct order.
  // Order matters: parent tables before child tables that
  // reference them (though SQLite does not enforce FKs by default).
  // ----------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {

    // ── TABLE 1: users ──────────────────────────────────────
    // Stores the logged-in user's account and profile data.
    // id = local UUID (different from Firebase uid)
    // uid = Firebase Auth UID used to find Firestore documents
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
    // Global exercise library — 873 exercises seeded from
    // Firestore on first launch via seedExercisesIfNeeded().
    // primaryMuscles, secondaryMuscles, instructions stored
    // as pipe-delimited strings e.g. "chest|shoulders"
    // imageUrl stores relative path e.g. "3_4_Sit-Up/0.jpg"
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
    // Workout templates — either predefined (seeded) or
    // created by the user via create_workout_screen.
    // isPredefined 0=user-created, 1=predefined
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        difficulty TEXT NOT NULL DEFAULT 'beginner',
        durationMinutes INTEGER NOT NULL DEFAULT 30,
        isPredefined INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── TABLE 4: workout_exercises ──────────────────────────
    // Junction table linking a workout to an exercise.
    // Stores user-chosen sets, reps, weight, rest, display order.
    // workoutId → workouts.id
    // exerciseId → exercises.id
    // orderIndex controls display order in the workout (ASC)
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
    // One row per workout attempt (started or completed).
    // endTime is NULL while the session is still active.
    // totalDuration stored in seconds.
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
    // One row per completed set during an active session.
    // setNumber is 1-based (Set 1, Set 2, Set 3...)
    // weight is NULL for bodyweight exercises
    // isCompleted 0=not done, 1=done
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
    // Daily nutrition summary — one row per user per date.
    // date stored as 'yyyy-MM-dd' for WHERE date=? queries.
    // Totals recalculated by nutrition_controller every time
    // a meal is added or deleted.
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
    // planId → nutrition_plans.id
    // mealType: breakfast|lunch|dinner|snack
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
    // One row per water intake tap (+250ml or +500ml button).
    // type: '250ml' or '500ml'
    // dailyGoalMl stored per entry to preserve historical accuracy
    // even if the user later changes their goal.
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
    // One mood log per entry from mental_health_screen.
    // mood: happy|calm|tired|stressed
    // note is nullable — user may log mood without writing notes
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
    // One row per medication the user tracks.
    // scheduleTimes stored as pipe-delimited string: "08:00|20:00"
    // endDate is NULL for open-ended medications
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
    // One row per user — tracks XP and level progress.
    // Updated by workout_controller after every session finish.
    // Level formula (computed in controller, not SQL):
    //   currentLevel  = totalXp ~/ 500
    //   xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
    // Each completed session awards +100 XP flat.
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
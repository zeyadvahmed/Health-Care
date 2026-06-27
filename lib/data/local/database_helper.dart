// ============================================================
// database_helper.dart
// lib/data/local/database_helper.dart
//
// PURPOSE:
//   Singleton that opens and manages the SQLite database file
//   sparksteel.db. Creates all app tables on first launch.
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
  // then opens it. 'version' is the schema version.
  // 'onCreate' only runs when the file does not exist yet.
  // ----------------------------------------------------------
  static Future<Database> _initDB() async {
    // getDatabasesPath() returns the device's documents directory
    final dbPath = await getDatabasesPath();
    // join() builds the full path: /data/user/.../sparksteel.db
    final path = join(dbPath, 'sparksteel.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate, // runs once on fresh install
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await _createMergedTablesIfMissing(db);

    await _addColumnIfMissing(db, 'workouts', 'imageUrl', 'imageUrl TEXT');

    await _addColumnIfMissing(db, 'mood_entries', 'userId', "userId TEXT DEFAULT ''");
    await _addColumnIfMissing(db, 'mood_entries', 'timestamp', 'timestamp TEXT');
    await _addColumnIfMissing(db, 'mood_entries', 'updatedAt', 'updatedAt TEXT');
    await _addColumnIfMissing(
      db,
      'mood_entries',
      'isSynced',
      'isSynced INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(db, 'mood_entries', 'date', 'date TEXT');
    await db.execute('''
      UPDATE mood_entries
      SET date = COALESCE(date, substr(timestamp, 1, 10)),
          timestamp = COALESCE(timestamp, date),
          updatedAt = COALESCE(updatedAt, timestamp, date)
      WHERE date IS NULL OR timestamp IS NULL OR updatedAt IS NULL
    ''');

    await _addColumnIfMissing(db, 'medical_records', 'notes', 'notes TEXT');
    await _addColumnIfMissing(
      db,
      'medical_records',
      'isTaken',
      'isTaken INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(db, 'medical_records', 'createdAt', 'createdAt TEXT');
    await db.execute('''
      UPDATE medical_records
      SET createdAt = COALESCE(createdAt, updatedAt, startDate)
      WHERE createdAt IS NULL OR createdAt = ''
    ''');
  }

  static Future<void> _createMergedTablesIfMissing(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nutrition_plans (
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        target_calories REAL NOT NULL DEFAULT 2000
      )
    ''');

    final goals = await db.query('daily_goals', limit: 1);
    if (goals.isEmpty) {
      await db.insert('daily_goals', {'target_calories': 2000});
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mood_entries (
        id TEXT PRIMARY KEY,
        userId TEXT DEFAULT '',
        mood TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        timestamp TEXT,
        updatedAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_moods (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        mood TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mental_exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('breathing','meditation')),
        duration_seconds INTEGER NOT NULL,
        description TEXT
      )
    ''');

    final mentalExercises = await db.query('mental_exercises', limit: 1);
    if (mentalExercises.isEmpty) {
      await _seedExercises(db);
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical_records (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'pill',
        dosage TEXT NOT NULL DEFAULT '',
        frequency TEXT NOT NULL DEFAULT 'once_daily',
        scheduleTimes TEXT NOT NULL DEFAULT '',
        startDate TEXT NOT NULL,
        endDate TEXT,
        notes TEXT,
        isTaken INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    }
  }

  Future<void> insertUserIfNotExists(Map<String, dynamic> userData) async {
    final db = await database;
    final uid = (userData['uid'] ?? userData['id'] ?? '').toString();
    final email = (userData['email'] ?? '').toString();
    final existing = await db.query(
      'users',
      where: uid.isNotEmpty ? 'uid = ?' : 'email = ?',
      whereArgs: [uid.isNotEmpty ? uid : email],
      limit: 1,
    );

    if (existing.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'id': (userData['id'] ?? uid).toString().isNotEmpty
          ? (userData['id'] ?? uid).toString()
          : email,
      'uid': uid,
      'name': (userData['name'] ?? '').toString(),
      'email': email,
      'profileImageUrl': userData['profileImageUrl'],
      'age': _toInt(userData['age']),
      'weight': _toDouble(userData['weight']),
      'height': _toDouble(userData['height']),
      'caloriesGoal': _toInt(userData['caloriesGoal']) ?? 2000,
      'waterGoal': _toInt(userData['waterGoal']) ?? 2500,
      'createdAt': (userData['createdAt'] ?? now).toString(),
      'updatedAt': (userData['updatedAt'] ?? now).toString(),
      'isSynced': userData['isSynced'] == true || userData['isSynced'] == 1
          ? 1
          : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'createdAt DESC');
  }

  Future<int> updateUser(Map<String, dynamic> userData, Object? userId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return db.update(
      'users',
      {
        if (userData.containsKey('uid')) 'uid': userData['uid'].toString(),
        if (userData.containsKey('name')) 'name': userData['name'].toString(),
        if (userData.containsKey('email')) 'email': userData['email'].toString(),
        if (userData.containsKey('profileImageUrl'))
          'profileImageUrl': userData['profileImageUrl'],
        if (userData.containsKey('age')) 'age': _toInt(userData['age']),
        if (userData.containsKey('weight'))
          'weight': _toDouble(userData['weight']),
        if (userData.containsKey('height'))
          'height': _toDouble(userData['height']),
        if (userData.containsKey('caloriesGoal'))
          'caloriesGoal': _toInt(userData['caloriesGoal']) ?? 2000,
        if (userData.containsKey('waterGoal'))
          'waterGoal': _toInt(userData['waterGoal']) ?? 2500,
        'updatedAt': now,
        'isSynced': userData['isSynced'] == true || userData['isSynced'] == 1
            ? 1
            : 0,
      },
      where: 'id = ?',
      whereArgs: [userId.toString()],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // ----------------------------------------------------------
  // _onCreate()
  // Runs exactly ONCE when the database file is first created.
  // Creates all 12 tables in the correct order.
  // Order matters: parent tables before child tables that
  // reference them (though SQLite does not enforce FKs by default).
  // ----------------------------------------------------------
  static Future<void> _onCreate(Database db, int version) async {

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
        imageUrl TEXT,
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

    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL
      
      )
    ''');

    // Daily goals table
    await db.execute('''
      CREATE TABLE daily_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        target_calories REAL NOT NULL DEFAULT 2000

      )
    ''');

    // Insert default goal
    await db.insert('daily_goals', {
      'target_calories': 2000,
    });
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
        userId TEXT DEFAULT '',
        mood TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        timestamp TEXT,
        updatedAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');


    await db.execute('''
      CREATE TABLE daily_moods (
        id         TEXT PRIMARY KEY,
        date       TEXT NOT NULL UNIQUE,                   
        mood       TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mental_exercises (
        id               TEXT PRIMARY KEY,
        name             TEXT NOT NULL,
        type             TEXT NOT NULL CHECK(type IN ('breathing','meditation')),
        duration_seconds INTEGER NOT NULL,
        description      TEXT
      )
    ''');


    await _seedExercises(db);

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
        notes TEXT,
        isTaken INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
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

  static Future<void> _seedExercises(Database db) async {
    final exercises = [
      {
        'id': 'ex_001',
        'name': 'Box Breathing',
        'type': 'breathing', 
        'duration_seconds': 240,
        'description': 'استنشق 4 ثواني، احبس 4، اخرج 4، احبس 4',
      },
      {
        'id': 'ex_002',
        'name': '4-7-8 Breathing',
        'type': 'breathing',
        'duration_seconds': 180,
        'description': 'استنشق 4، احبس 7، اخرج 8 ثواني',
      },
      {
        'id': 'ex_003',
        'name': 'Body Scan Meditation',
        'type': 'meditation',
        'duration_seconds': 600,
        'description': 'ركز على كل جزء من جسمك من القدم للرأس',
      },
      {
        'id': 'ex_004',
        'name': 'Mindfulness Meditation',
        'type': 'meditation',
        'duration_seconds': 300,
        'description': 'ركز على اللحظة الحالية بدون حكم',
      },
    ];
 
    for (final ex in exercises) {
      await db.insert('mental_exercises', ex);
    }
  }
}

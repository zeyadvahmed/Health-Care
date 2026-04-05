// ============================================================
// database_helper.dart
// Singleton that opens and manages the SQLite database file.
// Creates all 12 tables on first launch.
//
// Usage:
//   final db = await DatabaseHelper.instance.database;
//   await db.insert('workouts', workout.toMap());
//   await db.query('exercises', where: 'id = ?', whereArgs: [id]);
//
// Tables created:
//   users, exercises, workouts, workout_exercises,
//   workout_sessions, session_logs, nutrition_plans,
//   nutrition_meals, hydration_entries, mood_entries,
//   medical_records, activity
//
// Rules:
//   - Singleton pattern — only one instance exists at all times
//   - Call DatabaseHelper.instance.database to get the db reference
//   - Never instantiate directly — always use DatabaseHelper.instance
//   - Database file name: sparksteel.db
//   - All boolean fields stored as INTEGER (0 or 1)
//   - All DateTime fields stored as TEXT in ISO 8601 format
//   - All id fields are TEXT PRIMARY KEY (UUID strings)
// ============================================================
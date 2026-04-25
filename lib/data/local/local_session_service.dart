// ============================================================
// local_session_service.dart
// lib/data/local/local_session_service.dart
//
// PURPOSE:
//   All SQLite CRUD for workout_sessions and session_logs tables.
//
// SESSION LIFECYCLE:
//   1. User taps Start → insertSession() with endTime=null
//   2. User checks sets → insertSessionLog() for each set
//   3. User taps Finish → updateSession() with endTime + totals
//
// TWO TABLES MANAGED HERE:
//   workout_sessions → one row per workout attempt
//   session_logs     → one row per completed set
//
// RULES:
//   - getSessionsForUser() only returns COMPLETED sessions
//     (endTime IS NOT NULL). Active sessions are excluded.
//   - getLogsForSession() orders by setNumber ASC
//   - Singleton pattern
//   - No Flutter UI imports
// ============================================================

import 'package:sqflite/sqflite.dart';
import '../models/workout_session_model.dart';
import '../models/session_log_model.dart';
import 'database_helper.dart';

class LocalSessionService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  LocalSessionService._internal();
  static final LocalSessionService instance =
      LocalSessionService._internal();

  // ═══════════════════════════════════════════════════════════
  // WORKOUT_SESSIONS TABLE
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // insertSession()
  // Creates a new session row when the user taps Start Workout.
  // At this point:
  //   - endTime = null (session is active)
  //   - totalVolume = 0
  //   - totalDuration = 0
  //   - caloriesBurned = 0
  // These are all updated when the session finishes.
  // ----------------------------------------------------------
  Future<void> insertSession(WorkoutSessionModel session) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'workout_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // updateSession()
  // Updates an existing session row when the user finishes.
  // Called by workout_controller.finishSession() which sets:
  //   - endTime to now
  //   - totalVolume from sum of (reps × weight) across all sets
  //   - totalDuration from endTime - startTime in seconds
  //   - caloriesBurned from rough estimation
  // ----------------------------------------------------------
  Future<void> updateSession(WorkoutSessionModel session) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // ----------------------------------------------------------
  // getSessionsForUser()
  // Returns all COMPLETED sessions for a user.
  // 'endTime IS NOT NULL' excludes any active/abandoned sessions.
  // Ordered newest first so history screen shows recent workouts
  // at the top.
  // ----------------------------------------------------------
  Future<List<WorkoutSessionModel>> getSessionsForUser(
      String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workout_sessions',
      where: 'userId = ? AND endTime IS NOT NULL',
      whereArgs: [userId],
      orderBy: 'startTime DESC', // newest session first
    );
    return maps.map((map) => WorkoutSessionModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // getSessionById()
  // Returns a single session by id.
  // Returns null if not found.
  // ----------------------------------------------------------
  Future<WorkoutSessionModel?> getSessionById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WorkoutSessionModel.fromMap(maps.first);
  }

  // ----------------------------------------------------------
  // getUnsyncedSessions()
  // Returns all sessions where isSynced = 0.
  // Called by sync_service.
  // ----------------------------------------------------------
  Future<List<WorkoutSessionModel>> getUnsyncedSessions() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'workout_sessions',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => WorkoutSessionModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // markSessionSynced()
  // Sets isSynced = 1 for the given session id.
  // ----------------------------------------------------------
  Future<void> markSessionSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'workout_sessions',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SESSION_LOGS TABLE
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // insertSessionLog()
  // Inserts one set log when user taps a set checkbox.
  // Called immediately when user checks a set — not buffered.
  // weight is null for bodyweight exercises.
  // ----------------------------------------------------------
  Future<void> insertSessionLog(SessionLogModel log) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'session_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // getLogsForSession()
  // Returns all set logs for a session ordered by setNumber ASC.
  // Used by:
  //   - workout_summary_screen to display what was completed
  //   - workout_history_screen to show exercise breakdown
  //   - finishSession to calculate totalVolume
  // ----------------------------------------------------------
  Future<List<SessionLogModel>> getLogsForSession(
      String sessionId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'session_logs',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'setNumber ASC',
    );
    return maps.map((map) => SessionLogModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // getUnsyncedLogs()
  // Returns all session_logs where isSynced = 0.
  // ----------------------------------------------------------
  Future<List<SessionLogModel>> getUnsyncedLogs() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'session_logs',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => SessionLogModel.fromMap(map)).toList();
  }

  // ----------------------------------------------------------
  // markLogSynced()
  // Sets isSynced = 1 for the given session log id.
  // ----------------------------------------------------------
  Future<void> markLogSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'session_logs',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
// ============================================================
// local_activity_service.dart
// All SQLite read/write operations for the activity table.
// ============================================================

import 'package:sqflite/sqflite.dart';

import '../models/activity_model.dart';
import 'database_helper.dart';

class LocalActivityService {
  LocalActivityService._internal();
  static final LocalActivityService instance =
      LocalActivityService._internal();

  static const String _table = 'activity';

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      _table,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ActivityModel?> getActivityForUser(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ActivityModel.fromMap(rows.first);
  }

  Future<ActivityModel?> getActivityByUserId(String userId) {
    return getActivityForUser(userId);
  }

  Future<void> updateActivity(ActivityModel activity) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      _table,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<List<ActivityModel>> getUnsyncedActivity() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      _table,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return rows.map((row) => ActivityModel.fromMap(row)).toList();
  }

  Future<List<ActivityModel>> getUnsyncedActivities() {
    return getUnsyncedActivity();
  }

  Future<void> markActivitySynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      _table,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteActivity(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> activityExists(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $_table WHERE userId = ?',
      [userId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<int> getTotalXp(String userId) async {
    final activity = await getActivityForUser(userId);
    return activity?.totalXp ?? 0;
  }

  Future<int> getCurrentLevel(String userId) async {
    final activity = await getActivityForUser(userId);
    return activity?.currentLevel ?? 0;
  }

  Future<int> getXpToNextLevel(String userId) async {
    final activity = await getActivityForUser(userId);
    return activity?.xpToNextLevel ?? 500;
  }
}

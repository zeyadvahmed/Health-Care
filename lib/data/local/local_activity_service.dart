import 'package:sqflite/sqflite.dart';
import '../models/activity_model.dart';
import 'database_helper.dart';

class LocalActivityService {

  LocalActivityService._internal();
  static final LocalActivityService instance =
      LocalActivityService._internal();

  Future<void> insertActivity(ActivityModel activity) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ActivityModel?> getActivityByUserId(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'activities',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ActivityModel.fromMap(maps.first);
  }

  Future<List<ActivityModel>> getUnsyncedActivities() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'activities',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => ActivityModel.fromMap(map)).toList();
  }

  Future<void> markActivitySynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activities',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateActivity(ActivityModel activity) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<void> deleteActivity(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> activityExists(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM activities WHERE userId = ?',
      [userId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<int> getTotalXp(String userId) async {
    final activity = await getActivityByUserId(userId);
    return activity?.totalXp ?? 0;
  }

  Future<int> getCurrentLevel(String userId) async {
    final activity = await getActivityByUserId(userId);
    return activity?.currentLevel ?? 0;
  }

  Future<int> getXpToNextLevel(String userId) async {
    final activity = await getActivityByUserId(userId);
    return activity?.xpToNextLevel ?? 500;
  }
}

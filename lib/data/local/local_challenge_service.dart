import 'package:sqflite/sqflite.dart';
import '../models/activity_challenge_model.dart';
import 'database_helper.dart';

class LocalChallengeService {

  LocalChallengeService._internal();
  static final LocalChallengeService instance =
      LocalChallengeService._internal();

  Future<void> insertChallenge(ActivityChallengeModel challenge) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'activity_challenges',
      challenge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityChallengeModel>> getTodayChallenges(
      String userId) async {
    final db = await DatabaseHelper.instance.database;
    final today = _todayPrefix();
    final maps = await db.query(
      'activity_challenges',
      where: 'userId = ? AND challengeDate LIKE ?',
      whereArgs: [userId, '$today%'],
      orderBy: 'type ASC',
    );
    return maps
        .map((map) => ActivityChallengeModel.fromMap(map))
        .toList();
  }

  Future<ActivityChallengeModel?> getChallengeByType(
    String userId,
    String type,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final today = _todayPrefix();
    final maps = await db.query(
      'activity_challenges',
      where: 'userId = ? AND type = ? AND challengeDate LIKE ?',
      whereArgs: [userId, type, '$today%'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ActivityChallengeModel.fromMap(maps.first);
  }

  Future<void> updateProgress(String id, int newProgress) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activity_challenges',
      {
        'currentProgress': newProgress,
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeChallenge(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activity_challenges',
      {
        'completed': 1,
        'completedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> claimReward(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activity_challenges',
      {
        'rewardClaimed': 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateChallenge(ActivityChallengeModel challenge) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activity_challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<void> deleteChallenge(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'activity_challenges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> todayChallengesExist(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final today = _todayPrefix();
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM activity_challenges '
      'WHERE userId = ? AND challengeDate LIKE ?',
      [userId, '$today%'],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<List<ActivityChallengeModel>> getUnsyncedChallenges() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'activity_challenges',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps
        .map((map) => ActivityChallengeModel.fromMap(map))
        .toList();
  }

  Future<void> markChallengeSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'activity_challenges',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String _todayPrefix() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
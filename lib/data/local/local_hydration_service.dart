import 'package:sqflite/sqflite.dart';
import '../models/hydration_entry_model.dart';
import 'database_helper.dart';

class LocalHydrationService {

  LocalHydrationService._internal();
  static final LocalHydrationService instance =
      LocalHydrationService._internal();

  Future<void> insertEntry(HydrationEntryModel entry) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'hydration_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HydrationEntryModel>> getEntriesForToday(
      String userId) async {
    final db = await DatabaseHelper.instance.database;
    final today = _todayPrefix();
    final maps = await db.query(
      'hydration_entries',
      where: 'userId = ? AND timestamp LIKE ?',
      whereArgs: [userId, '$today%'],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => HydrationEntryModel.fromMap(map)).toList();
  }

  Future<int> getTotalMlForToday(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final today = _todayPrefix();
    final result = await db.rawQuery(
      'SELECT SUM(amountMl) FROM hydration_entries '
      'WHERE userId = ? AND timestamp LIKE ?',
      [userId, '$today%'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<HydrationEntryModel>> getUnsyncedEntries() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'hydration_entries',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => HydrationEntryModel.fromMap(map)).toList();
  }

  Future<void> markEntrySynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'hydration_entries',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEntry(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'hydration_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<HydrationEntryModel?> getHydrationEntryById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'hydration_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HydrationEntryModel.fromMap(maps.first);
  }

  String _todayPrefix() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

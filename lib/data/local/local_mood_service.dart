// ============================================================
// local_mood_service.dart
// All SQLite read/write operations for the mood_entries table.
//
// Usage:
//   await LocalMoodService.instance.insertEntry(entry);
//   final entries = await LocalMoodService.instance.getLastSevenDays(userId);
//   final latest = await LocalMoodService.instance.getLatestEntry(userId);
//
// Methods to implement:
//   insertEntry(MoodEntryModel)                  — insert one mood entry row
//   getAllEntries(String userId)                  — return all mood entries for user
//   getLastSevenDays(String userId)              — return entries from last 7 days
//                                                  used for bar chart in mental_health_screen
//   getLatestEntry(String userId)                — return most recent mood entry
//                                                  used in home_screen mood card
//   getUnsyncedEntries()                         — WHERE isSynced = 0
//   markEntrySynced(String id)                   — UPDATE isSynced = 1
//   deleteEntry(String id)                       — delete entry by id
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getLastSevenDays: WHERE timestamp >= date 7 days ago ORDER BY timestamp ASC
//   - getLatestEntry: ORDER BY timestamp DESC LIMIT 1
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================

import 'dart:developer';

import 'package:sparksteel/data/local/database_helper.dart';
import 'package:sparksteel/data/models/daily_mood.dart';
import 'package:sparksteel/data/models/guided_exercise.dart';
import 'package:sparksteel/data/models/mood_entry.dart';

class LocalMoodService {
  Future<void> insertMoodEntry(MoodEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('mood_entries', entry.toMap());
    log(entry.toString());
  }

  Future<void> upsertDailyMood(DailyMood dailymood) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('daily_moods',dailymood.toMap());
    
  }

  Future<List<MoodEntry>> getLast7DaysMoods() async {
    final db = await DatabaseHelper.instance.database;

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final cutoff =
        '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'daily_moods',
      where: 'date >= ?',
      whereArgs: [cutoff],
      orderBy: 'date DESC',
    );

    return maps.map((m) => MoodEntry.fromMap(m)).toList();
  }

  /// جلب المود اليومي ليوم معين
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('mood_entries', orderBy: 'date DESC');
    return maps.map((m) => MoodEntry.fromMap(m)).toList();
  }

  Future<List<DailyMood>> getAllDailyMoods() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('daily_moods', orderBy: 'date DESC');
    return maps.map((m) => DailyMood.fromMap(m)).toList();
  }

  Future<void> clearMoodData() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('mood_entries');
    await db.delete('daily_moods');
  }

  Future<DailyMood?> getDailyMoodByDate(String date) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'daily_moods',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyMood.fromMap(maps.first);
  }

  Future<List<GuidedExercise>> getAllExercises() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('mental_exercises', orderBy: 'type, name');
    return maps.map((m) => GuidedExercise.fromMap(m)).toList();
  }
 
  
  // Future<List<MentalExercise>> getExercisesByType(ExerciseType type) async {
  //   final db = await database;
  //   final maps = await db.query(
  //     'mental_exercises',
  //     where: 'type = ?',
  //     whereArgs: [type.name],
  //     orderBy: 'name',
  //   );
  //   return maps.map((m) => MentalExercise.fromMap(m)).toList();
  // }
}

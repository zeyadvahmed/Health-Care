// ============================================================
// remote_mood_service.dart
// Firestore read/write operations for mental health mood data.
//
// User data is stored under:
//   users/{uid}/mood_entries/{id}
//   users/{uid}/daily_moods/{date}
//
// Guided exercises are global:
//   mental_exercises/{id}
//
// These methods mirror LocalMoodService, with uid added for user data.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/daily_mood.dart';
import 'package:sparksteel/data/models/guided_exercise.dart';
import 'package:sparksteel/data/models/mood_entry.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteMoodService {
  RemoteMoodService._internal();
  static final RemoteMoodService instance = RemoteMoodService._internal();

  factory RemoteMoodService() => instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _guidedExercises = 'mental_exercises';
  static const int _batchSize = 450;

  String _moodEntriesPath(String uid) => 'User/$uid/mood_entries';
  String _dailyMoodsPath(String uid) => 'User/$uid/daily_moods';

  Future<void> insertMoodEntry(String uid, MoodEntry entry) async {
    await FirestoreService.instance.setDocument(
      _moodEntriesPath(uid),
      entry.id,
      entry.toMap(),
    );
  }

  Future<void> upsertDailyMood(String uid, DailyMood dailyMood) async {
    await FirestoreService.instance.setDocument(
      _dailyMoodsPath(uid),
      dailyMood.date,
      dailyMood.toMap(),
    );
  }

  Future<List<MoodEntry>> getLast7DaysMoods(String uid) async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final cutoff =
        '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';

    final snapshot = await _db
        .collection(_dailyMoodsPath(uid))
        .where('date', isGreaterThanOrEqualTo: cutoff)
        .get();

    final moods = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['note'] ??= '';
      return MoodEntry.fromMap(data);
    }).toList();

    moods.sort((a, b) => b.date.compareTo(a.date));
    return moods;
  }

  Future<List<MoodEntry>> getAllMoodEntries(String uid) async {
    final snapshot = await _db.collection(_moodEntriesPath(uid)).get();

    final entries = snapshot.docs
        .map((doc) => MoodEntry.fromMap(Map<String, dynamic>.from(doc.data())))
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<List<DailyMood>> getAllDailyMoods(String uid) async {
    final snapshot = await _db.collection(_dailyMoodsPath(uid)).get();

    final moods = snapshot.docs
        .map((doc) => DailyMood.fromMap(Map<String, dynamic>.from(doc.data())))
        .toList();
    moods.sort((a, b) => b.date.compareTo(a.date));
    return moods;
  }

  Future<void> pushAllMoodEntries(
    String uid,
    List<MoodEntry> entries,
  ) async {
    final collection = _moodEntriesPath(uid);
    final snapshot = await _db.collection(collection).get();
    final localIds = entries.map((entry) => entry.id).toSet();

    final operations = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      if (!localIds.contains(doc.id)) {
        operations.add({
          'type': 'delete',
          'collection': collection,
          'docId': doc.id,
        });
      }
    }

    for (final entry in entries) {
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': entry.id,
        'data': entry.toMap(),
      });
    }

    await _batchWriteInChunks(operations);
  }

  Future<void> pushAllDailyMoods(String uid, List<DailyMood> moods) async {
    final collection = _dailyMoodsPath(uid);
    final snapshot = await _db.collection(collection).get();
    final localDates = moods.map((mood) => mood.date).toSet();

    final operations = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      if (!localDates.contains(doc.id)) {
        operations.add({
          'type': 'delete',
          'collection': collection,
          'docId': doc.id,
        });
      }
    }

    for (final mood in moods) {
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': mood.date,
        'data': mood.toMap(),
      });
    }

    await _batchWriteInChunks(operations);
  }

  Future<DailyMood?> getDailyMoodByDate(String uid, String date) async {
    final data = await FirestoreService.instance.getDocument(
      _dailyMoodsPath(uid),
      date,
    );

    if (data == null) return null;
    return DailyMood.fromMap(data);
  }

  Future<List<GuidedExercise>> getAllExercises() async {
    final docs = await FirestoreService.instance.getCollection(
      _guidedExercises,
    );

    final exercises = docs
        .map((doc) => GuidedExercise.fromMap(_normalizeExerciseMap(doc)))
        .toList();
    exercises.sort((a, b) {
      final typeCompare = a.type.compareTo(b.type);
      if (typeCompare != 0) return typeCompare;
      return a.name.compareTo(b.name);
    });
    return exercises;
  }

  Future<void> pushGuidedExercise(GuidedExercise exercise) async {
    await FirestoreService.instance.setDocument(
      _guidedExercises,
      exercise.id,
      exercise.toMap(),
    );
  }

  Future<void> deleteMoodEntry(String uid, String id) async {
    await FirestoreService.instance.deleteDocument(
      _moodEntriesPath(uid),
      id,
    );
  }

  Map<String, dynamic> _normalizeExerciseMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'name': data['name'],
      'type': data['type'],
      'duration_seconds': _intValue(data['duration_seconds']),
    };
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _batchWriteInChunks(
    List<Map<String, dynamic>> operations,
  ) async {
    if (operations.isEmpty) return;

    for (var i = 0; i < operations.length; i += _batchSize) {
      final end = i + _batchSize < operations.length
          ? i + _batchSize
          : operations.length;
      await FirestoreService.instance.batchWrite(operations.sublist(i, end));
    }
  }
}

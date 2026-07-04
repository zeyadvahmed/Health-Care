// ============================================================
// remote_mood_service.dart
// Firestore read/write operations for mental health mood data.
//
// User data is stored under:
//   User/{uid}/mood_entries/{id}
//   User/{uid}/daily_moods/{date}
//
// These methods mirror LocalMoodService, with uid added for user data.
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/daily_mood.dart';
import 'package:sparksteel/data/models/mood_entry.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteMoodService {
  RemoteMoodService._internal();
  static final RemoteMoodService instance = RemoteMoodService._internal();
  factory RemoteMoodService() => instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _moodEntriesPath(String uid) => 'User/$uid/mood_entries';
  String _dailyMoodsPath(String uid) => 'User/$uid/daily_moods';

  Future<void> pushAllMoodEntries(String uid, List<MoodEntry> entries) async {
    final collection = _moodEntriesPath(uid);
    final snapshot = await _db.collection(collection).get();
    final remoteIds = snapshot.docs.map((d) => d.id).toSet();
    final localIds = entries.map((e) => e.id).toSet();

    // Delete remote docs that are not present locally
    for (final docId in remoteIds.difference(localIds)) {
      await FirestoreService.instance.deleteDocument(collection, docId);
    }

    // Write local entries to remote
    for (final entry in entries) {
      await FirestoreService.instance.setDocument(
        collection,
        entry.id,
        entry.toMap(),
      );
    }
  }

  Future<void> pushAllDailyMoods(String uid, List<DailyMood> moods) async {
    final collection = _dailyMoodsPath(uid);
    final snapshot = await _db.collection(collection).get();
    final remoteIds = snapshot.docs.map((d) => d.id).toSet();
    final localDates = moods.map((m) => m.date).toSet();

    
    for (final docId in remoteIds.difference(localDates)) {
      await FirestoreService.instance.deleteDocument(collection, docId);
    }

    
    for (final mood in moods) {
      await FirestoreService.instance.setDocument(
        collection,
        mood.date,
        mood.toMap(),
      );
    }
  }

  Future<List<MoodEntry>> getAllMoodEntries(String uid) async {
    final snapshot = await _db.collection(_moodEntriesPath(uid)).get();
    final items = snapshot.docs
      .map((d) => MoodEntry.fromMap(d.data()))
      .toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Future<List<DailyMood>> getAllDailyMoods(String uid) async {
    final snapshot = await _db.collection(_dailyMoodsPath(uid)).get();
    final items = snapshot.docs
      .map((d) => DailyMood.fromMap(d.data()))
      .toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }
}

// ============================================================
// remote_hydration_service.dart
// Firestore read/write operations for hydration data.
//
// User hydration entries are stored under:
//   User/{uid}/hydration_entries/{id}
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/hydration_entry_model.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteHydrationService {
  RemoteHydrationService._internal();
  static final RemoteHydrationService instance =
      RemoteHydrationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _batchSize = 450;

  String _hydrationEntriesPath(String uid) => 'User/$uid/hydration_entries';

  Future<void> pushEntry(
    HydrationEntryModel entry,
    String uid,
  ) async {
    await FirestoreService.instance.setDocument(
      _hydrationEntriesPath(uid),
      entry.id,
      entry.toFirestore(),
    );
  }

  Future<void> pushAllEntries(
    String uid,
    List<HydrationEntryModel> entries,
  ) async {
    final collection = _hydrationEntriesPath(uid);
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
        'data': entry.toFirestore(),
      });
    }

    await _batchWriteInChunks(operations);
  }

  Future<void> deleteEntry(
    String id,
    String uid,
  ) async {
    await FirestoreService.instance.deleteDocument(
      _hydrationEntriesPath(uid),
      id,
    );
  }

  Future<List<HydrationEntryModel>> fetchEntriesForUser(String uid) async {
    final docs = await FirestoreService.instance.getCollection(
      _hydrationEntriesPath(uid),
    );

    final entries = docs.map((doc) {
      return HydrationEntryModel.fromFirestore(_normalizeEntryMap(doc));
    }).toList();
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  Map<String, dynamic> _normalizeEntryMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'userId': data['userId'],
      'amountMl': _intValue(data['amountMl']),
      'type': data['type'] ?? '250ml',
      'dailyGoalMl': _intValue(data['dailyGoalMl'], fallback: 2500),
      'timestamp': _timestampValue(data['timestamp']),
      'updatedAt': _timestampValue(data['updatedAt']),
    };
  }

  int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Timestamp _timestampValue(dynamic value) {
    if (value is Timestamp) return value;
    return Timestamp.fromDate(
      DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now(),
    );
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

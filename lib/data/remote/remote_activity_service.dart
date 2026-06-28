// ============================================================
// remote_activity_service.dart
// Firestore read/write operations for user activity data.
//
// User activity is stored under:
//   User/{uid}/activity/{id}
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/activity_model.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteActivityService {
  RemoteActivityService._internal();
  static final RemoteActivityService instance =
      RemoteActivityService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _batchSize = 450;

  String _activityPath(String uid) => 'User/$uid/activity';

  Future<void> pushActivity(String uid, ActivityModel activity) async {
    await FirestoreService.instance.setDocument(
      _activityPath(uid),
      activity.id,
      activity.toFirestore(),
    );
  }

  Future<void> uploadActivity(String uid, ActivityModel activity) {
    return pushActivity(uid, activity);
  }

  Future<void> pushAllActivities(
    String uid,
    List<ActivityModel> activities,
  ) async {
    final collection = _activityPath(uid);
    final snapshot = await _db.collection(collection).get();
    final localIds = activities.map((activity) => activity.id).toSet();

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

    for (final activity in activities) {
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': activity.id,
        'data': activity.toFirestore(),
      });
    }

    await _batchWriteInChunks(operations);
  }

  Future<void> uploadActivitiesBatch(
    String uid,
    List<ActivityModel> activities,
  ) {
    return pushAllActivities(uid, activities);
  }

  Future<void> deleteActivity(String uid, String activityId) async {
    await FirestoreService.instance.deleteDocument(
      _activityPath(uid),
      activityId,
    );
  }

  Future<List<ActivityModel>> fetchActivities(String uid) async {
    final docs = await FirestoreService.instance.getCollection(
      _activityPath(uid),
    );

    final activities = docs.map((doc) {
      return ActivityModel.fromFirestore(_normalizeActivityMap(doc));
    }).toList();
    activities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return activities;
  }

  Future<ActivityModel?> fetchActivityById(
    String uid,
    String activityId,
  ) async {
    final data = await FirestoreService.instance.getDocument(
      _activityPath(uid),
      activityId,
    );

    if (data == null) return null;
    return ActivityModel.fromFirestore(_normalizeActivityMap(data));
  }

  Map<String, dynamic> _normalizeActivityMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'userId': data['userId'],
      'totalXp': _intValue(data['totalXp']),
      'currentLevel': _intValue(data['currentLevel']),
      'xpToNextLevel': _intValue(data['xpToNextLevel']),
      'updatedAt': data['updatedAt'] is Timestamp
          ? data['updatedAt']
          : Timestamp.fromDate(
              DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
                  DateTime.now(),
            ),
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

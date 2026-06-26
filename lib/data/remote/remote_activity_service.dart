import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class RemoteActivityService {

  RemoteActivityService._internal();
  static final RemoteActivityService instance =
      RemoteActivityService._internal();

  // The Firestore instance — accessed directly in this service
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _activitiesRef(String uid) =>
      _db.collection('users').doc(uid).collection('activities');

  Future<void> uploadActivity(
    String uid,
    ActivityModel activity,
  ) async {
    await _activitiesRef(uid)
        .doc(activity.id)
        .set(activity.toFirestore(), SetOptions(merge: true));
  }

  Future<void> uploadActivitiesBatch(
    String uid,
    List<ActivityModel> activities,
  ) async {
    final batch = _db.batch();

    for (final activity in activities) {
      final ref = _activitiesRef(uid).doc(activity.id);
      batch.set(ref, activity.toFirestore(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> deleteActivity(
    String uid,
    String activityId,
  ) async {
    await _activitiesRef(uid).doc(activityId).delete();
  }

  Future<List<ActivityModel>> fetchActivities(String uid) async {
    final snapshot = await _activitiesRef(uid)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ActivityModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<ActivityModel?> fetchActivityById(
    String uid,
    String activityId,
  ) async {
    final doc = await _activitiesRef(uid).doc(activityId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ActivityModel.fromFirestore(doc.data()!);
  }
}

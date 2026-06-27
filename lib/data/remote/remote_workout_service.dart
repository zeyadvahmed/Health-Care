// ============================================================
// remote_workout_service.dart
// lib/data/remote/remote_workout_service.dart
//
// PURPOSE:
//   All Firestore push/delete/fetch for workout-related data.
//
// COLLECTIONS:
//   workouts          → ROOT: firestore/workouts/{id}
//   workout_exercises → SUB:  users/{uid}/workout_exercises/{id}
//   workout_sessions  → SUB:  users/{uid}/workout_sessions/{id}
//   session_logs      → SUB:  users/{uid}/session_logs/{id}
//
// FETCH METHODS:
//   fetchWorkoutsForUser()          → used by restoreFromFirestore
//   fetchWorkoutExercisesForUser()  → used by restoreFromFirestore
//   fetchSessionsForUser()          → used by restoreFromFirestore
//   fetchLogsForUser()              → used by restoreFromFirestore
//
//   These are RESTORE-ONLY methods. Normal reads always come
//   from SQLite. Fetch methods only run on fresh install
//   when SQLite is empty and data needs to be pulled down.
//
// RULES:
//   - Singleton pattern
//   - Uses FirestoreService.instance
//   - Called ONLY by sync_service
//   - No Flutter UI imports
// ============================================================

import '../models/workout_model.dart';
import '../models/workout_exercise_model.dart';
import '../models/workout_session_model.dart';
import '../models/session_log_model.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoteWorkoutService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  RemoteWorkoutService._internal();
  static final RemoteWorkoutService instance =
      RemoteWorkoutService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _batchSize = 450;

  // Collection path constants and builders
  static const String _workouts = 'workouts';
  String _workoutExercisesPath(String uid) =>
      'User/$uid/workout_exercises';
  String _sessionsPath(String uid) =>
      'User/$uid/workout_sessions';
  String _logsPath(String uid) =>
      'User/$uid/session_logs';

  // ═══════════════════════════════════════════════════════════
  // PUSH — write to Firestore
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // pushWorkout()
  // Pushes a workout to the ROOT workouts collection.
  // setDocument creates or fully replaces — idempotent.
  // ----------------------------------------------------------
  Future<void> pushWorkout(WorkoutModel workout) async {
    await FirestoreService.instance.setDocument(
      _workouts,
      workout.id,
      workout.toFirestore(),
    );
  }

  // ----------------------------------------------------------
  // deleteWorkout()
  // Deletes a workout document from Firestore.
  // ----------------------------------------------------------
  Future<void> deleteWorkout(String id) async {
    await FirestoreService.instance.deleteDocument(_workouts, id);
  }

  // ----------------------------------------------------------
  // pushWorkoutExercise()
  // Pushes one workout_exercise to the user's subcollection.
  // uid is required to build the subcollection path.
  // ----------------------------------------------------------
  Future<void> pushWorkoutExercise(
      WorkoutExerciseModel we, String uid) async {
    await FirestoreService.instance.setDocument(
      _workoutExercisesPath(uid),
      we.id,
      we.toFirestore(),
    );
  }

  Future<void> pushAllWorkoutExercises(
    String uid,
    List<WorkoutExerciseModel> exercises,
  ) async {
    await _pushAllModels(
      collection: _workoutExercisesPath(uid),
      ids: exercises.map((item) => item.id),
      data: exercises.map((item) => item.toFirestore()),
    );
  }

  // ----------------------------------------------------------
  // pushSession()
  // Pushes a COMPLETED session to the user's subcollection.
  // Only called when endTime is NOT null (session finished).
  // ----------------------------------------------------------
  Future<void> pushSession(
      WorkoutSessionModel session, String uid) async {
    await FirestoreService.instance.setDocument(
      _sessionsPath(uid),
      session.id,
      session.toFirestore(),
    );
  }

  Future<void> pushAllSessions(
    String uid,
    List<WorkoutSessionModel> sessions,
  ) async {
    await _pushAllModels(
      collection: _sessionsPath(uid),
      ids: sessions.map((item) => item.id),
      data: sessions.map((item) => item.toFirestore()),
    );
  }

  // ----------------------------------------------------------
  // pushSessionLog()
  // Pushes one set log to the user's subcollection.
  // ----------------------------------------------------------
  Future<void> pushSessionLog(
      SessionLogModel log, String uid) async {
    await FirestoreService.instance.setDocument(
      _logsPath(uid),
      log.id,
      log.toFirestore(),
    );
  }

  Future<void> pushAllSessionLogs(
    String uid,
    List<SessionLogModel> logs,
  ) async {
    await _pushAllModels(
      collection: _logsPath(uid),
      ids: logs.map((item) => item.id),
      data: logs.map((item) => item.toFirestore()),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH — read from Firestore (restore-only, not normal flow)
  // ═══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // fetchWorkoutsForUser()
  // Fetches all workouts belonging to a user from Firestore.
  // Filters by userId field inside each document.
  //
  // RESTORE-ONLY: called by sync_service.restoreFromFirestore()
  // on fresh install when the local workouts table is empty.
  // Normal reads always come from SQLite.
  //
  // fromFirestore() handles DateTime ← Timestamp conversion.
  // ----------------------------------------------------------
  Future<List<WorkoutModel>> fetchWorkoutsForUser(
      String userId) async {
    final docs = await FirestoreService.instance.getCollection(
      _workouts,
      whereField: 'userId',
      isEqualTo: userId,
    );
    return docs
        .map((doc) => WorkoutModel.fromFirestore(doc))
        .toList();
  }

  // ----------------------------------------------------------
  // fetchWorkoutExercisesForUser()
  // Fetches ALL workout_exercise documents from the user's
  // subcollection. No filter needed — the subcollection path
  // already scopes results to this user only.
  //
  // Sorts by orderIndex ASC client-side since getCollection()
  // does not support orderBy — preserves exercise order.
  //
  // RESTORE-ONLY: called by restoreFromFirestore() on login
  // when local workout_exercises table is empty.
  // ----------------------------------------------------------
  Future<List<WorkoutExerciseModel>> fetchWorkoutExercisesForUser(
      String uid) async {
    final docs = await FirestoreService.instance.getCollection(
      _workoutExercisesPath(uid),
      // No filter — subcollection is already scoped to this user
    );
    final exercises = docs
        .map((doc) => WorkoutExerciseModel.fromFirestore(doc))
        .toList();
    // Sort locally — Firestore doesn't guarantee order
    exercises.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return exercises;
  }

  // ----------------------------------------------------------
  // fetchSessionsForUser()
  // Fetches all COMPLETED workout sessions from the user's
  // subcollection. Filters out active sessions (endTime = null)
  // because active sessions are never pushed to Firestore.
  //
  // RESTORE-ONLY: called by restoreFromFirestore() on login.
  // ----------------------------------------------------------
  Future<List<WorkoutSessionModel>> fetchSessionsForUser(
      String uid) async {
    final docs = await FirestoreService.instance.getCollection(
      _sessionsPath(uid),
      // No filter — all docs in this subcollection are completed
      // sessions (active sessions are never pushed to Firestore)
    );
    return docs
        .map((doc) => WorkoutSessionModel.fromFirestore(doc))
        .toList();
  }

  // ----------------------------------------------------------
  // fetchLogsForUser()
  // Fetches ALL session log documents from the user's
  // subcollection. Returns every set ever logged.
  //
  // NOTE: This fetches all logs across all sessions.
  // If the user has 100 sessions with 30 sets each, this is
  // 3000 Firestore reads. Called only ONCE on fresh install.
  //
  // RESTORE-ONLY: called by restoreFromFirestore() on login.
  // ----------------------------------------------------------
  Future<List<SessionLogModel>> fetchLogsForUser(
      String uid) async {
    final docs = await FirestoreService.instance.getCollection(
      _logsPath(uid),
    );
    return docs
        .map((doc) => SessionLogModel.fromFirestore(doc))
        .toList();
  }

  Future<void> _pushAllModels({
    required String collection,
    required Iterable<String> ids,
    required Iterable<Map<String, dynamic>> data,
  }) async {
    final idList = ids.toList();
    final dataList = data.toList();
    final snapshot = await _db.collection(collection).get();
    final localIds = idList.toSet();

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

    for (var i = 0; i < idList.length; i++) {
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': idList[i],
        'data': dataList[i],
      });
    }

    await _batchWriteInChunks(operations);
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

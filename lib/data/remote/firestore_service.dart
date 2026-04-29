// ============================================================
// firestore_service.dart
// lib/data/remote/firestore_service.dart
//
// PURPOSE:
//   Generic base Firestore CRUD service.
//   All remote feature services call this — they never touch
//   FirebaseFirestore.instance directly.
//
// WHY THIS EXISTS:
//   If Firestore's API changes, or we want to add logging,
//   error handling, or retry logic — we change it in ONE place
//   instead of touching every remote service file.
//
// HOW SUBCOLLECTIONS WORK IN THIS APP:
//   workout_sessions, nutrition_plans, nutrition_meals,
//   hydration_entries, mood_entries, medical_records,
//   workout_exercises, session_logs all live under users/{uid}/
//   Example path: users/abc123/workout_sessions/session456
//
//   For subcollections, callers pass the full path as collection:
//   'users/$uid/workout_sessions'
//
//   For root collections (workouts, exercises, activity):
//   'workouts', 'exercises', 'activity'
//
// RULES:
//   - Singleton pattern — one instance only
//   - Never called from controllers or screens
//   - All methods throw on failure — let callers handle errors
//   - No Flutter imports — pure Dart + cloud_firestore
// ============================================================

// ignore: uri_does_not_exist
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  // The Firestore instance from Firebase SDK
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // setDocument()
  // Creates a document if it doesn't exist, or completely
  // replaces it if it does. Used when syncing a record
  // from SQLite to Firestore for the first time or re-syncing.
  //
  // collection: e.g. 'workouts' or 'users/$uid/workout_sessions'
  // docId:      the document's UUID string
  // data:       the map from model.toFirestore()
  // ----------------------------------------------------------
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  // ----------------------------------------------------------
  // getDocument()
  // Fetches a single document by its path.
  // Returns the data map or null if the document doesn't exist.
  // Used by auth_controller to check if a user doc exists
  // after sign-in.
  // ----------------------------------------------------------
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final snapshot = await _db.collection(collection).doc(docId).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  // ----------------------------------------------------------
  // updateDocument()
  // Partially updates specific fields in an existing document.
  // Only the fields in 'data' change — all other fields remain.
  // Different from setDocument() which replaces everything.
  // ----------------------------------------------------------
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  // ----------------------------------------------------------
  // deleteDocument()
  // Permanently deletes a document from Firestore.
  // Called by remote services when user deletes data locally.
  // ----------------------------------------------------------
  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // ----------------------------------------------------------
  // getCollection()
  // Fetches all documents from a collection with an optional
  // single WHERE filter.
  // Used by remote_exercise_service.fetchAllExercises() to
  // get all 873 exercises on first launch.
  //
  // whereField: the field name to filter on e.g. 'userId'
  // isEqualTo:  the value to match e.g. 'abc123'
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    String? whereField,
    dynamic isEqualTo,
  }) async {
    Query query = _db.collection(collection);

    // Apply optional filter
    if (whereField != null && isEqualTo != null) {
      query = query.where(whereField, isEqualTo: isEqualTo);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // ----------------------------------------------------------
  // batchWrite()
  // Writes multiple documents in one Firestore batch.
  // All operations succeed together or all fail together.
  //
  // IMPORTANT: Firestore batch limit is 500 operations.
  // For 873 exercises we split into multiple batches externally.
  //
  // Each operation map must contain:
  //   'type'       → 'set' | 'update' | 'delete'
  //   'collection' → collection path string
  //   'docId'      → document ID string
  //   'data'       → Map<String,dynamic> (not needed for delete)
  // ----------------------------------------------------------
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _db.batch();

    for (final op in operations) {
      final ref = _db
          .collection(op['collection'] as String)
          .doc(op['docId'] as String);

      switch (op['type'] as String) {
        case 'set':
          batch.set(ref, op['data'] as Map<String, dynamic>);
          break;
        case 'update':
          batch.update(ref, op['data'] as Map<String, dynamic>);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    }

    await batch.commit();
  }
}

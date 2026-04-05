// ============================================================
// firestore_service.dart
// Generic base Firestore CRUD methods used by all remote services.
//
// Usage:
//   await FirestoreService.instance.setDocument('users', userId, data);
//   final data = await FirestoreService.instance.getDocument('users', userId);
//   await FirestoreService.instance.updateDocument('workouts', id, fields);
//   await FirestoreService.instance.deleteDocument('workouts', id);
//   final list = await FirestoreService.instance.getCollection('workouts',
//     where: 'userId', isEqualTo: userId);
//
// Methods to implement:
//   setDocument(String collection, String docId, Map data)     — create or overwrite doc
//   getDocument(String collection, String docId)               — fetch single doc, returns
//                                                                null if not found
//   updateDocument(String collection, String docId, Map data)  — partial update fields
//   deleteDocument(String collection, String docId)            — delete single doc
//   getCollection(String collection, {String? where,           — fetch filtered collection
//     dynamic isEqualTo})
//   batchWrite(List<Map> operations)                           — write multiple docs atomically
//
// Rules:
//   - Used only by remote feature services — never called from controllers directly
//   - All methods throw exceptions on failure
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
// ============================================================
// remote_mood_service.dart
// Firestore push methods for mood entries.
//
// Usage:
//   await RemoteMoodService.instance.pushEntry(entry);
//   await RemoteMoodService.instance.deleteEntry(id);
//
// Methods to implement:
//   pushEntry(MoodEntryModel)        — write entry to 'mood_entries' collection
//   deleteEntry(String id)           — delete entry doc from Firestore
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
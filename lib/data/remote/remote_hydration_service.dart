// ============================================================
// remote_hydration_service.dart
// Firestore push methods for hydration entries.
//
// Usage:
//   await RemoteHydrationService.instance.pushEntry(entry);
//   await RemoteHydrationService.instance.deleteEntry(id);
//
// Methods to implement:
//   pushEntry(HydrationEntryModel)   — write entry to 'hydration_entries' collection
//   deleteEntry(String id)           — delete entry doc from Firestore
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
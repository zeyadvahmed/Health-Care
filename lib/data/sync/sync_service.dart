// ============================================================
// sync_service.dart
// Bridge between local SQLite and Firestore.
// Finds all unsynced records and pushes them to Firestore.
//
// Usage:
//   await SyncService.instance.syncAll();
//   await SyncService.instance.syncWorkouts();
//
// Methods to implement:
//   syncAll()              — runs all sync methods below in sequence
//                            checks connectivity first, skips if offline
//   syncUsers()            — push unsynced users, mark synced
//   syncExercises()        — push unsynced exercises, mark synced
//   syncWorkouts()         — push unsynced workouts + workout_exercises, mark synced
//   syncSessions()         — push unsynced sessions + session_logs, mark synced
//   syncNutrition()        — push unsynced plans + meals, mark synced
//   syncHydration()        — push unsynced hydration entries, mark synced
//   syncMood()             — push unsynced mood entries, mark synced
//   syncMedical()          — push unsynced medical records, mark synced
//   syncActivity()         — push unsynced activity records, mark synced
//
// Rules:
//   - Always check ConnectivityService.instance.isOnline() before any sync
//   - Each feature syncs independently — one failure must not stop others
//     wrap each syncX() call in its own try/catch inside syncAll()
//   - After pushing each record mark it synced in SQLite immediately
//   - No Flutter UI imports — pure Dart only
// ============================================================
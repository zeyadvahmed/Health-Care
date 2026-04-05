// ============================================================
// local_mood_service.dart
// All SQLite read/write operations for the mood_entries table.
//
// Usage:
//   await LocalMoodService.instance.insertEntry(entry);
//   final entries = await LocalMoodService.instance.getLastSevenDays(userId);
//   final latest = await LocalMoodService.instance.getLatestEntry(userId);
//
// Methods to implement:
//   insertEntry(MoodEntryModel)                  — insert one mood entry row
//   getAllEntries(String userId)                  — return all mood entries for user
//   getLastSevenDays(String userId)              — return entries from last 7 days
//                                                  used for bar chart in mental_health_screen
//   getLatestEntry(String userId)                — return most recent mood entry
//                                                  used in home_screen mood card
//   getUnsyncedEntries()                         — WHERE isSynced = 0
//   markEntrySynced(String id)                   — UPDATE isSynced = 1
//   deleteEntry(String id)                       — delete entry by id
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getLastSevenDays: WHERE timestamp >= date 7 days ago ORDER BY timestamp ASC
//   - getLatestEntry: ORDER BY timestamp DESC LIMIT 1
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
// ============================================================
// local_hydration_service.dart
// All SQLite read/write operations for the hydration_entries table.
//
// Usage:
//   await LocalHydrationService.instance.insertEntry(entry);
//   final total = await LocalHydrationService.instance.getTotalMlForToday(userId);
//   final entries = await LocalHydrationService.instance.getEntriesForToday(userId);
//
// Methods to implement:
//   insertEntry(HydrationEntryModel)             — insert one entry row
//   getEntriesForToday(String userId)            — WHERE userId = ? AND timestamp
//                                                  starts with today's date string
//   getTotalMlForToday(String userId)            — SUM(amountMl) for today's entries
//   getUnsyncedEntries()                         — WHERE isSynced = 0
//   markEntrySynced(String id)                   — UPDATE isSynced = 1
//   deleteEntry(String id)                       — delete entry by id
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - Filter today's entries using: WHERE timestamp LIKE 'yyyy-MM-dd%'
//   - getTotalMlForToday returns 0 if no entries exist yet
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
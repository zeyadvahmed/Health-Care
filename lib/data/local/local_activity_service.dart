// ============================================================
// local_activity_service.dart
// All SQLite read/write operations for the activity table.
// Stores XP and level data for the user.
//
// Usage:
//   await LocalActivityService.instance.insertActivity(activity);
//   final activity = await LocalActivityService.instance.getActivityForUser(userId);
//   await LocalActivityService.instance.updateActivity(activity);
//
// Methods to implement:
//   insertActivity(ActivityModel)                — insert first activity row for user
//   getActivityForUser(String userId)            — return activity record for user
//                                                  returns null if never completed a workout
//   updateActivity(ActivityModel)                — update XP and level after workout
//   getUnsyncedActivity()                        — WHERE isSynced = 0
//   markActivitySynced(String id)                — UPDATE isSynced = 1
//
// XP logic (handled in workout_controller, not here):
//   +100 XP per completed workout session
//   currentLevel  = totalXp ~/ 500
//   xpToNextLevel = ((currentLevel + 1) * 500) - totalXp
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - One row per user — insertActivity only called once per user ever
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
// ============================================================
// local_session_service.dart
// All SQLite read/write operations for workout_sessions and session_logs tables.
//
// Usage:
//   await LocalSessionService.instance.insertSession(session);
//   await LocalSessionService.instance.updateSession(session);
//   final history = await LocalSessionService.instance.getSessionsForUser(userId);
//
// Methods to implement:
//   insertSession(WorkoutSessionModel)           — insert one session row
//   updateSession(WorkoutSessionModel)           — update session (called when finished)
//   getSessionsForUser(String userId)            — return all completed sessions for user
//   getSessionById(String id)                    — return single session
//   getUnsyncedSessions()                        — WHERE isSynced = 0
//   markSessionSynced(String id)                 — UPDATE isSynced = 1
//
//   insertSessionLog(SessionLogModel)            — insert one set log row
//   getLogsForSession(String sessionId)          — return all logs for one session
//   getUnsyncedLogs()                            — WHERE isSynced = 0
//   markLogSynced(String id)                     — UPDATE isSynced = 1
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getSessionsForUser should ORDER BY startTime DESC (newest first)
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
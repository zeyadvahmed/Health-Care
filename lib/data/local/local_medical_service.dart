// ============================================================
// local_medical_service.dart
// All SQLite read/write operations for the medical_records table.
//
// Usage:
//   await LocalMedicalService.instance.insertRecord(record);
//   final records = await LocalMedicalService.instance.getAllRecords(userId);
//   await LocalMedicalService.instance.deleteRecord(id);
//
// Methods to implement:
//   insertRecord(MedicalRecordModel)             — insert one medical record row
//   getAllRecords(String userId)                 — return all records for user
//   getRecordById(String id)                     — return single record
//   updateRecord(MedicalRecordModel)             — update existing record
//   deleteRecord(String id)                      — delete record by id
//   getUnsyncedRecords()                         — WHERE isSynced = 0
//   markRecordSynced(String id)                  — UPDATE isSynced = 1
//
// Rules:
//   - Always get db via DatabaseHelper.instance.database
//   - getAllRecords should ORDER BY startDate DESC
//   - No Flutter imports — pure Dart + sqflite only
// ============================================================
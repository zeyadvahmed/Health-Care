// ============================================================
// medical_controller.dart
// Manages medication records and taken status.
//
// Usage:
//   final controller = MedicalController();
//   await controller.loadMedications(userId);
//   await controller.saveMedication(record);
//   await controller.deleteMedication(id);
//
// State to expose:
//   bool isLoading                          — true while loading
//   List<MedicalRecordModel> medications    — all medications for user
//
// Methods to implement:
//   loadMedications(String userId)          — load all records from SQLite
//   saveMedication(MedicalRecordModel)      — insert record, call sync
//   updateMedication(MedicalRecordModel)    — update record, call sync
//   deleteMedication(String id)             — delete record, call sync
//
// Rules:
//   - Always call sync_service.syncAll() after every change
//   - No Flutter UI imports except material.dart if needed
// ============================================================
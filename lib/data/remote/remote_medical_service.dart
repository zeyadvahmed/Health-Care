// ============================================================
// remote_medical_service.dart
// Firestore push methods for medical records.
//
// Usage:
//   await RemoteMedicalService.instance.pushRecord(record);
//   await RemoteMedicalService.instance.deleteRecord(id);
//
// Methods to implement:
//   pushRecord(MedicalRecordModel)   — write record to 'medical_records' collection
//   deleteRecord(String id)          — delete record doc from Firestore
//
// Rules:
//   - Called only by sync_service — never from controllers directly
//   - Uses FirestoreService.instance as the base layer
//   - No Flutter UI imports — pure Dart + cloud_firestore only
// ============================================================
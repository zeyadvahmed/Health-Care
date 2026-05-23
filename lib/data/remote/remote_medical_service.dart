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


import '../models/medical_record_model.dart';
import 'firestore_service.dart';

class RemoteMedicalService {


  RemoteMedicalService._internal();
  static final RemoteMedicalService instance =
      RemoteMedicalService._internal();


  String _medicalRecordsPath(String uid) =>
      'users/$uid/medical_records';

  Future<void> pushMedicalRecord(
    MedicalRecordModel record,
    String uid,
  ) async {
    await FirestoreService.instance.setDocument(
      _medicalRecordsPath(uid),
      record.id,
      record.toFirestore(),
    );
  }

  Future<void> deleteMedicalRecord(
    String id,
    String uid,
  ) async {
    await FirestoreService.instance.deleteDocument(
      _medicalRecordsPath(uid),
      id,
    );
  }


  Future<List<MedicalRecordModel>> fetchMedicalRecordsForUser(
    String uid,
  ) async {
    final docs = await FirestoreService.instance.getCollection(
      _medicalRecordsPath(uid),
    );
    return docs
        .map((doc) => MedicalRecordModel.fromFirestore(doc))
        .toList();
  }
}

// ============================================================
// remote_medical_service.dart
// Firestore read/write operations for medical tracker data.
//
// User medical records are stored under:
//   User/{uid}/medical_records/{id}
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparksteel/data/models/medical_record_model.dart';
import 'package:sparksteel/data/remote/firestore_service.dart';

class RemoteMedicalService {
  RemoteMedicalService._internal();
  static final RemoteMedicalService instance =
      RemoteMedicalService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _batchSize = 450;

  String _medicalRecordsPath(String uid) => 'User/$uid/medical_records';

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

  Future<void> pushAllMedicalRecords(
    String uid,
    List<MedicalRecordModel> records,
  ) async {
    final collection = _medicalRecordsPath(uid);
    final snapshot = await _db.collection(collection).get();
    final localIds = records.map((record) => record.id).toSet();

    final operations = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      if (!localIds.contains(doc.id)) {
        operations.add({
          'type': 'delete',
          'collection': collection,
          'docId': doc.id,
        });
      }
    }

    for (final record in records) {
      operations.add({
        'type': 'set',
        'collection': collection,
        'docId': record.id,
        'data': record.toFirestore(),
      });
    }

    await _batchWriteInChunks(operations);
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

    final records = docs.map((doc) {
      return MedicalRecordModel.fromFirestore(_normalizeRecordMap(doc));
    }).toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Map<String, dynamic> _normalizeRecordMap(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'userId': data['userId'],
      'name': data['name'],
      'type': data['type'] ?? 'pill',
      'dosage': data['dosage'] ?? '',
      'frequency': data['frequency'] ?? 'once_daily',
      'scheduleTimes': List<String>.from(data['scheduleTimes'] ?? []),
      'startDate': data['startDate'],
      'endDate': data['endDate'],
      'updatedAt': _timestampValue(data['updatedAt']),
      'isTaken': data['isTaken'] ?? false,
      'notes': data['notes'],
      'createdAt': _timestampValue(data['createdAt']),
    };
  }

  Timestamp _timestampValue(dynamic value) {
    if (value is Timestamp) return value;
    return Timestamp.fromDate(
      DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Future<void> _batchWriteInChunks(
    List<Map<String, dynamic>> operations,
  ) async {
    if (operations.isEmpty) return;

    for (var i = 0; i < operations.length; i += _batchSize) {
      final end = i + _batchSize < operations.length
          ? i + _batchSize
          : operations.length;
      await FirestoreService.instance.batchWrite(operations.sublist(i, end));
    }
  }
}

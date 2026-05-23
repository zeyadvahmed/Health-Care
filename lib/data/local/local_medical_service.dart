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

import 'package:sqflite/sqflite.dart';
import '../models/medical_record_model.dart';
import 'database_helper.dart';

class LocalMedicalService {

  LocalMedicalService._internal();
  static final LocalMedicalService instance =
      LocalMedicalService._internal();


  Future<void> insertMedicalRecord(MedicalRecordModel record) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'medical_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicalRecordModel>> getAllMedicalRecords(
      String userId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'medical_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MedicalRecordModel.fromMap(map)).toList();
  }


  Future<MedicalRecordModel?> getMedicalRecordById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'medical_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MedicalRecordModel.fromMap(maps.first);
  }


  Future<void> updateMedicalRecord(MedicalRecordModel record) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'medical_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }


  Future<void> deleteMedicalRecord(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'medical_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<List<MedicalRecordModel>> getUnsyncedMedicalRecords() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'medical_records',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => MedicalRecordModel.fromMap(map)).toList();
  }


  Future<void> markMedicalRecordSynced(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'medical_records',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

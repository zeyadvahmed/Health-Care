import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/medical_record_model.dart';
import '../../../data/local/local_medical_service.dart';
import '../../../data/sync/sync_service.dart';
import 'medical_state.dart';

class MedicalCubit extends Cubit<MedicalState> {
  
  MedicalCubit() : super(MedicalInitial());


  Future<void> loadMedicalRecords(String userId) async {
    emit(MedicalLoading());
    try {
      final records = await LocalMedicalService.instance
          .getAllMedicalRecords(userId);
      emit(MedicalLoaded(records));
    } catch (e) {
      emit(MedicalError('Could not load medical records.'));
    }
  }


  Future<void> addMedicalRecord(
    MedicalRecordModel record,
    String uid,
  ) async {
    emit(MedicalLoading());
    try {
      // Stamp timestamps and mark as unsynced before insert
      final prepared = record.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await LocalMedicalService.instance.insertMedicalRecord(prepared);

      // Push to Firestore if online — silently skips if offline.
      // isSynced = 0 guarantees the record is picked up on the
      // next sync cycle when connectivity is restored.
      await SyncService.instance.syncAll(uid);

      // Reload from SQLite — single source of truth
      await loadMedicalRecords(record.userId);
    } catch (e) {
      emit(MedicalError('Could not save medical record.'));
    }
  }


  Future<void> updateMedicalRecord(
    MedicalRecordModel record,
    String uid,
  ) async {
    emit(MedicalLoading());
    try {
      // Always re-stamp updatedAt and reset isSynced on update
      final prepared = record.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await LocalMedicalService.instance.updateMedicalRecord(prepared);

      await SyncService.instance.syncAll(uid);

      await loadMedicalRecords(record.userId);
    } catch (e) {
      emit(MedicalError('Could not update medical record.'));
    }
  }


  Future<void> deleteMedicalRecord(
    String id,
    String userId,
    String uid,
  ) async {
    emit(MedicalLoading());
    try {
      // Delete locally first — SQLite is always the source of truth
      await LocalMedicalService.instance.deleteMedicalRecord(id);

      await SyncService.instance.syncAll(uid);

      await loadMedicalRecords(userId);
    } catch (e) {
      emit(MedicalError('Could not delete medical record.'));
    }
  }


  Future<MedicalRecordModel?> getMedicalRecordById(String id) async {
    return await LocalMedicalService.instance.getMedicalRecordById(id);
  }
}

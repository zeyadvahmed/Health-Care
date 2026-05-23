// ============================================================
// medical_cubit.dart
// lib/features/medical_tracker/cubit/medical_cubit.dart
//
// PURPOSE:
//   Controls all state and CRUD operations for the medical
//   tracker feature. Acts as the single business logic layer
//   between the UI and the data layer.
//
// WHAT IT MANAGES:
//   - loading all medications for a user from SQLite
//   - adding new medication entries
//   - editing existing medication entries
//   - deleting medication entries
//   - fetching a single record by id for edit pre-fill
//
// ARCHITECTURE:
//   SQLite is always the source of truth.
//   All writes go to SQLite first — never directly to Firestore.
//   Firestore sync is triggered through SyncService.syncAll()
//   after every successful write. SyncService handles the rest.
//
// STATE MANAGEMENT:
//   Uses flutter_bloc Cubit<MedicalState>.
//   Every operation follows this exact flow:
//     1. emit MedicalLoading()
//     2. perform SQLite operation
//     3. trigger SyncService
//     4. reload from SQLite → emit MedicalLoaded()
//     5. on any error → emit MedicalError(message)
//
// RULES:
//   - Never store BuildContext
//   - Never import screens or UI widgets
//   - Never call Firestore directly — only through SyncService
//   - Never use ChangeNotifier or notifyListeners
//   - Always reload after write to keep UI in sync with SQLite
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/medical_record_model.dart';
import '../../../data/local/local_medical_service.dart';
import '../../../data/sync/sync_service.dart';
import 'medical_state.dart';

class MedicalCubit extends Cubit<MedicalState> {

  // ----------------------------------------------------------
  // CONSTRUCTOR
  // Starts at MedicalInitial — no data loaded yet.
  // The UI must call loadMedicalRecords() after creation.
  // ----------------------------------------------------------
  MedicalCubit() : super(MedicalInitial());

  // ══════════════════════════════════════════════════════════
  // READ
  // ══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // loadMedicalRecords()
  //
  // PURPOSE:
  //   Fetches all medication records for the given user from
  //   SQLite and emits MedicalLoaded with the result.
  //
  // FLOW:
  //   1. emit MedicalLoading() — UI shows spinner
  //   2. query SQLite via LocalMedicalService
  //   3. emit MedicalLoaded(records) — UI renders the list
  //   4. on error → emit MedicalError with message
  //
  // IMPORTANT:
  //   This method is also called internally after every write
  //   (add / update / delete) to keep the UI in sync with the
  //   latest SQLite state. It is the single reload mechanism.
  //
  // userId = the app's internal user UUID (not Firebase UID)
  // ----------------------------------------------------------
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

  // ══════════════════════════════════════════════════════════
  // CREATE
  // ══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // addMedicalRecord()
  //
  // PURPOSE:
  //   Inserts a new medication record into SQLite, then
  //   triggers a Firestore sync and reloads the list.
  //
  // FLOW:
  //   1. emit MedicalLoading()
  //   2. stamp updatedAt = now, force isSynced = false
  //   3. insert into SQLite via LocalMedicalService
  //   4. call SyncService.syncAll(uid) — pushes to Firestore
  //      if device is online; silently skips if offline
  //   5. reload records → emit MedicalLoaded
  //   6. on error → emit MedicalError
  //
  // WHY copyWith HERE:
  //   The record arriving from the UI may have a stale
  //   updatedAt or isSynced = true from a previous state.
  //   We always stamp fresh values before writing to SQLite
  //   to guarantee correctness regardless of what the UI sent.
  //
  // uid    = Firebase Auth UID — passed to SyncService for
  //          Firestore subcollection path building
  // record = the new MedicalRecordModel to persist
  // ----------------------------------------------------------
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

  // ══════════════════════════════════════════════════════════
  // UPDATE
  // ══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // updateMedicalRecord()
  //
  // PURPOSE:
  //   Updates an existing medication record in SQLite, then
  //   triggers a Firestore sync and reloads the list.
  //
  // FLOW:
  //   1. emit MedicalLoading()
  //   2. stamp updatedAt = now, force isSynced = false
  //   3. update row in SQLite via LocalMedicalService
  //   4. call SyncService.syncAll(uid)
  //   5. reload records → emit MedicalLoaded
  //   6. on error → emit MedicalError
  //
  // WHY isSynced = false:
  //   The record was just changed locally. The previously
  //   synced Firestore version is now stale. Setting
  //   isSynced = false ensures SyncService will re-push
  //   the updated version on the next sync cycle.
  //
  // uid    = Firebase Auth UID for SyncService path building
  // record = the full updated MedicalRecordModel to persist
  // ----------------------------------------------------------
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

  // ══════════════════════════════════════════════════════════
  // DELETE
  // ══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // deleteMedicalRecord()
  //
  // PURPOSE:
  //   Removes a medication record from SQLite, triggers sync,
  //   and reloads the list to reflect the deletion in the UI.
  //
  // FLOW:
  //   1. emit MedicalLoading()
  //   2. delete from SQLite by id via LocalMedicalService
  //   3. call SyncService.syncAll(uid)
  //   4. reload records → emit MedicalLoaded
  //   5. on error → emit MedicalError
  //
  // NOTE ON FIRESTORE DELETION:
  //   SyncService.syncAll() handles pushing unsynced records
  //   but does NOT handle deletes — there is no isSynced
  //   mechanism for deletions. The controller or a dedicated
  //   delete sync flow must handle Firestore cleanup separately
  //   if hard-delete in Firestore is required.
  //
  // id     = the MedicalRecordModel.id to delete
  // userId = app's internal user UUID — used to reload list
  // uid    = Firebase Auth UID — passed to SyncService
  // ----------------------------------------------------------
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

  // ══════════════════════════════════════════════════════════
  // FETCH SINGLE
  // ══════════════════════════════════════════════════════════

  // ----------------------------------------------------------
  // getMedicalRecordById()
  //
  // PURPOSE:
  //   Fetches a single medical record by its id from SQLite.
  //   Used by the edit screen to pre-fill form fields before
  //   the user makes changes.
  //
  // RETURNS:
  //   The matching MedicalRecordModel, or null if not found.
  //   Callers must handle the null case — do not force-unwrap.
  //
  // NOTE:
  //   This method does NOT emit any state. It is a direct
  //   lookup helper — it does not affect the UI state stream.
  //   The edit screen calls this once on init to load the
  //   record into its local form state.
  // ----------------------------------------------------------
  Future<MedicalRecordModel?> getMedicalRecordById(String id) async {
    return await LocalMedicalService.instance.getMedicalRecordById(id);
  }
}

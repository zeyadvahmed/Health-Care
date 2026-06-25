import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/hydration_entry_model.dart';
import '../../../data/local/local_hydration_service.dart';
import '../../../data/sync/sync_service.dart';
import 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {

  HydrationCubit() : super(HydrationInitial());

  Future<void> loadHydrationEntries(String userId) async {
    emit(HydrationLoading());
    try {
      final entries = await LocalHydrationService.instance
          .getEntriesForToday(userId);
      emit(HydrationLoaded(entries));
    } catch (e) {
      emit(HydrationError('Could not load hydration entries.'));
    }
  }

  Future<void> addHydrationEntry(
    HydrationEntryModel entry,
    String uid,
  ) async {
    emit(HydrationLoading());
    try {
      // Stamp timestamps and mark as unsynced before insert
      final prepared = entry.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await LocalHydrationService.instance.insertEntry(prepared);

      // Push to Firestore if online — silently skips if offline.
      // isSynced = 0 guarantees the entry is picked up on the
      // next sync cycle when connectivity is restored.
      await SyncService.instance.syncAll(uid);

      // Reload from SQLite — single source of truth
      await loadHydrationEntries(entry.userId);
    } catch (e) {
      emit(HydrationError('Could not save hydration entry.'));
    }
  }

  Future<void> updateHydrationEntry(
    HydrationEntryModel entry,
    String uid,
  ) async {
    emit(HydrationLoading());
    try {
      // Always re-stamp updatedAt and reset isSynced on update
      final prepared = entry.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await LocalHydrationService.instance.insertEntry(prepared);

      await SyncService.instance.syncAll(uid);

      await loadHydrationEntries(entry.userId);
    } catch (e) {
      emit(HydrationError('Could not update hydration entry.'));
    }
  }

  Future<void> deleteHydrationEntry(
    String id,
    String userId,
    String uid,
  ) async {
    emit(HydrationLoading());
    try {
      // Delete locally first — SQLite is always the source of truth
      await LocalHydrationService.instance.deleteEntry(id);

      await SyncService.instance.syncAll(uid);

      await loadHydrationEntries(userId);
    } catch (e) {
      emit(HydrationError('Could not delete hydration entry.'));
    }
  }

  Future<HydrationEntryModel?> getHydrationEntryById(String id) async {
    return await LocalHydrationService.instance.getHydrationEntryById(id);
  }
}

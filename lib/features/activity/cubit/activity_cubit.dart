import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/local/local_activity_service.dart';
import '../../../data/sync/sync_service.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {

  ActivityCubit() : super(ActivityInitial());

  Future<void> loadActivity(String userId) async {
    emit(ActivityLoading());
    try {
      ActivityModel? activity =
          await LocalActivityService.instance.getActivityByUserId(userId);

      // First-time user — create a default activity record
      if (activity == null) {
        activity = ActivityModel(
          id: const Uuid().v4(),
          userId: userId,
          totalXp: 0,
          currentLevel: 0,
          xpToNextLevel: 500,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        await LocalActivityService.instance.insertActivity(activity);
      }

      emit(ActivityLoaded(activity));
    } catch (e) {
      emit(ActivityError('Could not load activity data.'));
    }
  }

  Future<void> awardXp({
    required String userId,
    required String uid,
    int xpAmount = 100,
  }) async {
    emit(ActivityLoading());
    try {
      ActivityModel? existing =
          await LocalActivityService.instance.getActivityByUserId(userId);

      // Create default record if user has none yet
      existing ??= ActivityModel(
        id: const Uuid().v4(),
        userId: userId,
        totalXp: 0,
        currentLevel: 0,
        xpToNextLevel: 500,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      // Compute updated XP and level
      final newTotalXp = existing.totalXp + xpAmount;
      final newLevel = newTotalXp ~/ 500;
      final newXpToNext = ((newLevel + 1) * 500) - newTotalXp;

      final updated = existing.copyWith(
        totalXp: newTotalXp,
        currentLevel: newLevel,
        xpToNextLevel: newXpToNext,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      // Upsert: insert if new, update if existing
      final exists =
          await LocalActivityService.instance.activityExists(userId);
      if (exists) {
        await LocalActivityService.instance.updateActivity(updated);
      } else {
        await LocalActivityService.instance.insertActivity(updated);
      }

      await SyncService.instance.syncAll(uid);
      await loadActivity(userId);
    } catch (e) {
      emit(ActivityError('Could not award XP.'));
    }
  }
}
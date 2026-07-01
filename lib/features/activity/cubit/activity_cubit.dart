import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/activity_challenge_model.dart';
import '../../../data/local/local_activity_service.dart';
import '../../../data/local/local_challenge_service.dart';
import '../../../data/sync/sync_service.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {

  ActivityCubit() : super(ActivityInitial());

  Future<void> loadActivity(String userId, String uid) async {
    emit(ActivityLoading());
    try {
      // Fetch or create the activity record
      ActivityModel? activity =
          await LocalActivityService.instance.getActivityByUserId(userId);

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

      // Seed today's challenges if not yet created for today
      await seedTodayChallenges(userId);

      // Load today's challenges
      final challenges =
          await LocalChallengeService.instance.getTodayChallenges(userId);

      emit(ActivityLoaded(activity: activity, challenges: challenges));
    } catch (e) {
      emit(ActivityError('Could not load activity data.'));
    }
  }

  Future<void> refreshChallenges(String userId) async {
    try {
      ActivityModel? activity =
          await LocalActivityService.instance.getActivityByUserId(userId);
      if (activity == null) return;

      final challenges =
          await LocalChallengeService.instance.getTodayChallenges(userId);

      emit(ActivityLoaded(activity: activity, challenges: challenges));
    } catch (e) {
      emit(ActivityError('Could not refresh challenges.'));
    }
  }

  Future<void> seedTodayChallenges(String userId) async {
    final exists =
        await LocalChallengeService.instance.todayChallengesExist(userId);
    if (exists) return;

    final now = DateTime.now();
    // challengeDate = midnight of today for date scoping
    final today = DateTime(now.year, now.month, now.day);

    final defaults = [
      _buildChallenge(
        userId: userId,
        type: 'hydration',
        title: 'Drink 4 glasses of water',
        description: 'Stay hydrated throughout the day',
        target: 4,
        xpReward: 30,
        challengeDate: today,
      ),
      _buildChallenge(
        userId: userId,
        type: 'nutrition',
        title: 'Log all meals',
        description: 'Track breakfast, lunch, and dinner',
        target: 3,
        xpReward: 50,
        challengeDate: today,
      ),
      _buildChallenge(
        userId: userId,
        type: 'workout',
        title: 'Complete a workout',
        description: 'Finish any workout session',
        target: 1,
        xpReward: 100,
        challengeDate: today,
      ),
      _buildChallenge(
        userId: userId,
        type: 'meditation',
        title: 'Meditate for 10 mins',
        description: 'Clear your mind with a session',
        target: 1,
        xpReward: 100,
        challengeDate: today,
      ),
      _buildChallenge(
        userId: userId,
        type: 'medication',
        title: 'Take all medications',
        description: 'Mark all medications as taken',
        target: 1,
        xpReward: 40,
        challengeDate: today,
      ),
    ];

    for (final challenge in defaults) {
      await LocalChallengeService.instance.insertChallenge(challenge);
    }
  }

  ActivityChallengeModel _buildChallenge({
    required String userId,
    required String type,
    required String title,
    required String description,
    required int target,
    required int xpReward,
    required DateTime challengeDate,
  }) {
    return ActivityChallengeModel(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      description: description,
      type: type,
      target: target,
      xpReward: xpReward,
      challengeDate: challengeDate,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  Future<void> updateChallengeProgress(
    String userId,
    String uid,
    String type,
    int delta,
  ) async {
    try {
      final challenge = await LocalChallengeService.instance
          .getChallengeByType(userId, type);

      // Challenge not found or already completed — nothing to do
      if (challenge == null || challenge.completed) return;

      final newProgress = (challenge.currentProgress + delta)
          .clamp(0, challenge.target);

      await LocalChallengeService.instance
          .updateProgress(challenge.id, newProgress);

      // Auto-complete if target reached
      if (newProgress >= challenge.target) {
        await LocalChallengeService.instance.completeChallenge(challenge.id);

        // Notify UI that challenge completed
        final completed = challenge.copyWith(
          currentProgress: newProgress,
          completed: true,
          completedAt: DateTime.now(),
        );
        emit(ChallengeCompleted(completed));

        // Auto-claim reward
        await claimChallengeReward(userId, uid, challenge.id);
      }

      await refreshChallenges(userId);
      await SyncService.instance.syncAll(uid);
    } catch (e) {
      // Silent fail — progress update should not crash other features
    }
  }

  Future<void> claimChallengeReward(
    String userId,
    String uid,
    String challengeId,
  ) async {
    try {
      // Re-fetch the latest state of the challenge
      final challenges =
          await LocalChallengeService.instance.getTodayChallenges(userId);
      final challenge = challenges
          .where((c) => c.id == challengeId)
          .firstOrNull;

      if (challenge == null) return;
      if (!challenge.completed) return;
      if (challenge.rewardClaimed) return; // guard — no double XP

      // Mark reward as claimed BEFORE awarding XP
      await LocalChallengeService.instance.claimReward(challenge.id);

      // Award XP — this may trigger level-up
      await awardXp(userId: userId, uid: uid, xpAmount: challenge.xpReward);

      emit(RewardClaimed(
        xpAwarded: challenge.xpReward,
        challengeTitle: challenge.title,
      ));
    } catch (e) {
      // Silent fail — reward claim should not surface to user
    }
  }

  Future<void> awardXp({
    required String userId,
    required String uid,
    int xpAmount = 100,
  }) async {
    try {
      ActivityModel? existing =
          await LocalActivityService.instance.getActivityByUserId(userId);

      existing ??= ActivityModel(
        id: const Uuid().v4(),
        userId: userId,
        totalXp: 0,
        currentLevel: 0,
        xpToNextLevel: 500,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      final oldLevel = existing.currentLevel;
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

      final exists =
          await LocalActivityService.instance.activityExists(userId);
      if (exists) {
        await LocalActivityService.instance.updateActivity(updated);
      } else {
        await LocalActivityService.instance.insertActivity(updated);
      }

      // Emit level-up BEFORE reloading so BlocListener catches it
      if (newLevel > oldLevel) {
        emit(ActivityLevelUp(
          oldLevel: oldLevel,
          newLevel: newLevel,
          earnedXp: xpAmount,
        ));
      }

      await SyncService.instance.syncAll(uid);
    } catch (e) {
      // XP award failures are silent — sync will retry later
    }
  }
}
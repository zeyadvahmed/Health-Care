import '../../../data/models/activity_model.dart';
import '../../../data/models/activity_challenge_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  // User's XP record — totalXp, currentLevel, xpToNextLevel
  final ActivityModel activity;

  // Today's challenges from SQLite — drives the entire list UI
  final List<ActivityChallengeModel> challenges;

  ActivityLoaded({
    required this.activity,
    required this.challenges,
  });
}

class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
}

class ActivityLevelUp extends ActivityState {
  final int oldLevel;
  final int newLevel;
  final int earnedXp;

  ActivityLevelUp({
    required this.oldLevel,
    required this.newLevel,
    required this.earnedXp,
  });
}

class ChallengeCompleted extends ActivityState {
  final ActivityChallengeModel challenge;
  ChallengeCompleted(this.challenge);
}

class RewardClaimed extends ActivityState {
  final int xpAwarded;
  final String challengeTitle;
  RewardClaimed({required this.xpAwarded, required this.challengeTitle});
}
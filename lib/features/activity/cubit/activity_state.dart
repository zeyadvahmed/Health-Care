import '../../../data/models/activity_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  // The user's full activity record from SQLite.
  // Contains XP totals, level info, and progression data.
  final ActivityModel activity;

  ActivityLoaded(this.activity);
}

class ActivityError extends ActivityState {
  // Human-readable error description shown to the user.
  final String message;

  ActivityError(this.message);
}
import '../../../data/models/hydration_entry_model.dart';


abstract class HydrationState {}

class HydrationInitial extends HydrationState {}

class HydrationLoading extends HydrationState {}

class HydrationLoaded extends HydrationState {
  // Today's hydration entries ordered by timestamp ASC
  // as returned by LocalHydrationService.getEntriesForToday().
  final List<HydrationEntryModel> entries;

  HydrationLoaded(this.entries);
}

class HydrationError extends HydrationState {
  // Human-readable error description shown to the user.
  final String message;

  HydrationError(this.message);
}

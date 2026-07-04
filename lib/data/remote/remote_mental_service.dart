// Lightweight wrapper: remote_mental_service.dart
// Quick compatibility layer that mirrors RemoteNutritionService shape
// but delegates to the existing RemoteMoodService implementation.

import 'package:sparksteel/data/models/mood_entry.dart';
import 'package:sparksteel/data/remote/remote_mood_service.dart';

class RemoteMentalService {
  RemoteMentalService._internal();
  static final RemoteMentalService instance = RemoteMentalService._internal();


  

  /// Push local notes list to remote (replace remote set with local set).
  Future<void> pushAllNotes(String uid, List<MoodEntry> notes) async {
    await RemoteMoodService.instance.pushAllMoodEntries(uid, notes);
  }

  
}

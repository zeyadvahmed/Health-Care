import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/data/local/local_mood_service.dart';
import 'package:sparksteel/data/sync/sync_service.dart';
import 'package:sparksteel/features/mental_health/logic/mental_state.dart';
import 'package:sparksteel/data/models/daily_mood.dart';
import 'package:sparksteel/data/models/guided_exercise.dart';
import 'package:sparksteel/data/models/mood_entry.dart';

class MentalCubit extends Cubit<MentalState> {
  MentalCubit() : super(MentalIntialState());

  String currentMood = 'Happy';
  void changeMood(String mood) {
    currentMood = mood;
    emit(ChangeMoodState());
  }

  final noteController = TextEditingController();

  Future<void> addMoodSmart(MoodEntry entry) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final existing = await LocalMoodService().getDailyMoodByDate(todayStr);

    if (existing == null) {
      LocalMoodService().upsertDailyMood(
        DailyMood(id: entry.id, mood: entry.mood, date: entry.date),
      );
    }
    await LocalMoodService().insertMoodEntry(entry);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await SyncService.instance.syncAll(uid);
    }
    noteController.clear();
  }

  List<GuidedExercise> guidedExercises = [];

  Future<void> getGuidedExercises() async {
    emit(GuidedExercisesLoading());
    final exercises = await LocalMoodService().getAllExercises();
    guidedExercises = exercises;
    emit(GuidedExercisesSuccess());
  }
}

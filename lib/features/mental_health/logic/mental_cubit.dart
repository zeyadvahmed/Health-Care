import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/data/local/local_mood_service.dart';
import 'package:sparksteel/features/mental_health/logic/mental_state.dart';
import 'package:sparksteel/features/mental_health/model/daily_mood.dart';
import 'package:sparksteel/features/mental_health/model/guided_exercise.dart';
import 'package:sparksteel/features/mental_health/model/mood_entry.dart';

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

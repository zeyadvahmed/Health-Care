import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/workout_model.dart';
import '../../data/services/workout_service.dart';

class WorkoutCubit
    extends Cubit<List<WorkoutModel>> {

  WorkoutCubit() : super([]);

  final WorkoutService
      workoutService =
      WorkoutService();

  List<WorkoutModel>
      allWorkouts = [];

  Future<void> loadWorkouts()
      async {

    final workouts =
        await workoutService
            .getWorkouts();

    allWorkouts = workouts;

    emit(workouts);
  }

  Future<void> addWorkout(
    WorkoutModel workout,
  ) async {

    await workoutService
        .insertWorkout(workout);

    loadWorkouts();
  }

  Future<void> deleteWorkout(
    int id,
  ) async {

    await workoutService
        .deleteWorkout(id);

    loadWorkouts();
  }

  Future<void> updateWorkout(
    WorkoutModel workout,
  ) async {

    await workoutService
        .updateWorkout(workout);

    loadWorkouts();
  }

  void searchWorkout(
    String query,
  ) {

    if (query.isEmpty) {

      emit(allWorkouts);

      return;
    }

    final filteredWorkouts =
        allWorkouts.where((workout) {

      return workout.title
          .toLowerCase()
          .contains(
            query.toLowerCase(),
          );

    }).toList();

    emit(filteredWorkouts);
  }
}
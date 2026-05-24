import 'package:sparlsteel/data/database/database_helper.dart';

import 'package:sparlsteel/data/models/workout_model.dart';

class WorkoutService {

  final DatabaseHelper
      _databaseHelper =
      DatabaseHelper();

  // INSERT
  Future<void> insertWorkout(
    WorkoutModel workout,
  ) async {

    final db =
        await _databaseHelper.database;

    await db.insert(
      'workouts',
      workout.toMap(),
    );
  }

  // GET ALL
  Future<List<WorkoutModel>>
      getWorkouts() async {

    final db =
        await _databaseHelper.database;

    final List<Map<String, dynamic>>
        maps =
        await db.query(
      'workouts',
    );

    return List.generate(
      maps.length,
      (index) {

        return WorkoutModel.fromMap(
          maps[index],
        );
      },
    );
  }

  // DELETE
  Future<void> deleteWorkout(
    int id,
  ) async {

    final db =
        await _databaseHelper.database;

    await db.delete(

      'workouts',

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // UPDATE
  Future<void> updateWorkout(
    WorkoutModel workout,
  ) async {

    final db =
        await _databaseHelper.database;

    await db.update(

      'workouts',

      workout.toMap(),

      where: 'id = ?',

      whereArgs: [workout.id],
    );
  }
}
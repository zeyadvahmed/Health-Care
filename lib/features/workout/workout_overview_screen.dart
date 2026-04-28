// ============================================================
// workout_overview_screen.dart
// Preview screen shown before starting a workout session.
//
// What to build:
//   - CustomAppBar with workout name and back button
//   - Date and UPCOMING badge row
//   - Info card showing estimated duration and exercise count
//   - List of ExerciseTiles showing each exercise with sets/reps/rest
//     each tile has Edit → Navigator.push to add_exercise_screen
//     and Delete → remove from list
//   - Start Workout CustomButton at bottom
//     → calls workoutController.startSession(workoutId, userId)
//     → Navigator.push to workout_session_screen with session data
//
// Receives via constructor:
//   WorkoutModel workout
//
// Rules:
//   - StatefulWidget — exercise list can be edited before starting
//   - Navigated to via Navigator.push (not pushNamed) with WorkoutModel
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class WorkoutOverviewScreen extends StatelessWidget {
  const WorkoutOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Workout Overview Screen')),
    );
  }
}
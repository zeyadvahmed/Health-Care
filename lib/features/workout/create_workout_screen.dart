// ============================================================
// create_workout_screen.dart
// Form screen for creating a new workout template.
//
// What to build:
//   - CustomAppBar title: 'Create Workout' with back button
//   - Workout name CustomTextField (validator: Validators.validateWorkoutName)
//   - Description CustomTextField optional (no validator)
//   - Difficulty dropdown: beginner / intermediate / expert
//   - Duration stepper or field in minutes
//   - SectionHeader 'Exercises'
//   - ExerciseSearchField widget for inline autocomplete
//   - List of added WorkoutExerciseTiles with delete button
//   - Bottom bar showing estimated duration and Save Workout CustomButton
//     → calls workoutController.saveWorkout(workout, exercises)
//     → Navigator.pop after save
//
// Rules:
//   - StatefulWidget — form, growing exercise list, multiple state changes
//   - Validate form before saving
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class CreateWorkoutScreen extends StatelessWidget {
  const CreateWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Create Workout Screen')),
    );
  }
}
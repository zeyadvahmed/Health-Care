// ============================================================
// add_exercise_screen.dart
// Form for defining one exercise to add to a workout.
//
// What to build:
//   - CustomAppBar title: 'Add Exercise' with back button
//   - ExerciseSearchField for exercise name with autocomplete
//   - Muscle group dropdown (auto-fills when exercise selected from search)
//   - Sets stepper with + and - buttons (min 1)
//   - Reps stepper with + and - buttons (min 1)
//   - Weight CustomTextField with KG/LBS toggle
//     use Helpers.kgToLbs / lbsToKg for conversion
//   - Rest time chips: 30s / 60s / 90s / 120s (single select)
//   - Optional notes CustomTextField
//   - Save Exercise CustomButton at bottom
//     → Navigator.pop(context, workoutExercise) to return data
//
// Rules:
//   - StatefulWidget — many interactive elements with state
//   - Return WorkoutExerciseModel via pop, do not save to DB from here
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Add Exercise Screen')),
    );
  }
}
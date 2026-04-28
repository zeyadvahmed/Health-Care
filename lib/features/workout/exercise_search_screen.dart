
// ============================================================
// exercise_search_screen.dart
// Full screen dedicated to browsing and searching exercises.
// Read only — no data is returned, just for exploration.
//
// What to build:
//   - CustomAppBar title: 'Exercises' with back button
//   - Search bar at top (CustomTextField or plain TextFormField)
//     calls workoutController.searchExercises(query) on every keystroke
//   - If query is empty → show all exercises (workoutController.loadAllExercises)
//   - Results list of ExerciseSearchResultTiles
//   - If no results → EmptyStateWidget 'No exercises found'
//
// Rules:
//   - StatefulWidget — results update on every keystroke
//   - Navigated to via pushNamed(AppRoutes.exerciseSearch) from home_screen
//   - No data passed back — read only screen
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class ExerciseSearchScreen extends StatelessWidget {
  const ExerciseSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Exercise Search Screen')),
    );
  }
}
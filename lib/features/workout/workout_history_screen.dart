// ============================================================
// workout_history_screen.dart
// Shows past workout sessions filterable by date.
//
// What to build:
//   - CustomAppBar title: 'Workout History' with back button
//   - Horizontal date picker row at the top (last 7 days)
//     tapping a date filters the session list below
//   - List of expandable session cards, each showing:
//       difficulty badge, duration, total volume, sets completed
//       expanded: breakdown of exercises with reps chips
//   - If no sessions for selected date → EmptyStateWidget
//
// Controller usage:
//   - Call workoutController.loadSessions(userId) in initState
//   - Filter sessions client-side by selected date
//
// Rules:
//   - StatefulWidget — date picker selection changes the list
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Workout History Screen')),
    );
  }
}
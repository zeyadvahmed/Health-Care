// ============================================================
// workout_summary_screen.dart
// Shown after finishing a session. Displays stats and XP earned.
//
// What to build:
//   - Celebration header with trophy/confetti icon
//   - XP earned badge using session data
//   - Grid of 4 StatBadges: Duration, Total Volume, Exercises, Calories
//   - CustomProgressBar showing XP progress toward next level
//     use activityController.activity for level data
//   - Save and Exit CustomButton
//     → pushNamedAndRemoveUntil(AppRoutes.home)
//
// Receives via constructor:
//   WorkoutSessionModel session
//   List<SessionLogModel> logs
//
// Rules:
//   - StatelessWidget — fixed data from completed session, nothing changes
//   - Navigated to via Navigator.push (not pushNamed)
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Workout Summary Screen')),
    );
  }
}
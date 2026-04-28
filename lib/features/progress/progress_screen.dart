// ============================================================
// progress_screen.dart
// Charts and stats overview across all features.
//
// What to build:
//   - CustomAppBar title: 'Progress'
//   - Workout section:
//       Two StatBadges: 'This Week' count and 'Total' count
//       Line chart of activity trend (weekly/monthly toggle)
//   - Nutrition section:
//       Avg daily intake StatBadge, adherence percentage StatBadge
//   - Hydration section:
//       Weekly bar chart using progressController.weekHydration
//   - Mental Health section:
//       Mood trend label, area chart using progressController.moodTrend
//
// Controller usage:
//   - Call progressController.loadProgressData(userId) in initState
//   - Weekly/monthly toggle updates chart data — reload or filter client-side
//
// Rules:
//   - StatefulWidget — toggle switches chart data
//   - Use fl_chart or charts_flutter for all charts if available in pubspec
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Progress Screen')),
    );
  }
}
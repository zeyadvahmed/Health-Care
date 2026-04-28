// ============================================================
// hydration_screen.dart
// Water intake tracking screen.
//
// What to build:
//   - CustomAppBar title: 'Hydration'
//   - Large CircularTracker showing totalMlToday vs dailyGoalMl
//   - Stats row: percentage complete, remaining amount
//   - Two CustomButtons side by side: '+250ml' and '+500ml'
//     each calls hydrationController.addWater(...)
//   - SectionHeader 'Today's Log'
//   - Scrollable list of hydration entries showing type, time, amount
//     each entry has a delete button
//
// Controller usage:
//   - Call hydrationController.loadTodayData(userId) in initState
//   - Show LoadingWidget while isLoading is true
//
// Rules:
//   - StatefulWidget — ring and list update on every water addition
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class HydrationScreen extends StatelessWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hydration Screen')),
    );
  }
}
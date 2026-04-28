// ============================================================
// activity_screen.dart
// XP, level, and leaderboard screen.
//
// What to build:
//   - CustomAppBar title: 'Activity'
//   - Header row: AvatarWidget, level badge, total XP text
//   - Current progress card:
//       level number large, XP fraction (e.g. 350/500),
//       CustomProgressBar for XP to next level,
//       motivational next level message
//   - Friends Leaderboard SectionHeader + ranked list
//     (static placeholder data is fine until Firestore leaderboard is ready)
//   - Show LevelUpDialog when activityController.didLevelUp is true
//     → call in initState or after loading completes
//
// Controller usage:
//   - Call activityController.loadActivity(userId) in initState
//
// Rules:
//   - StatefulWidget — XP updates throughout the day
//   - Reset didLevelUp to false after dialog is shown
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Activity Screen')),
    );
  }
}
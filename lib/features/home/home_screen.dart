// ============================================================
// home_screen.dart
// Main dashboard shown after login.
//
// What to build:
//   - CustomAppBar with greeting text from Helpers.getGreeting()
//     and avatar from homeController.user
//   - MoodSelector card using homeController.latestMood
//   - CircularTracker card for water using homeController.todayWaterMl
//   - WorkoutCard for today's workout using homeController.todayWorkout
//     if null → EmptyStateWidget with 'No workout today'
//   - SectionHeader 'Explore' with grid of feature buttons:
//       Workout, Nutrition, Hydration, Mental Health, Medical Tracker
//       each navigates with pushNamed to its route
//   - FAB for chatbot → pushNamed(AppRoutes.chatbot)
//   - Action button for exercise search → pushNamed(AppRoutes.exerciseSearch)
//   - BottomNavBar at the bottom
//
// Controller usage:
//   - Call homeController.loadHomeData(userId) in initState
//   - Show LoadingWidget while homeController.isLoading is true
//
// Rules:
//   - StatefulWidget — loads data on init
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Screen')),
    );
  }
}
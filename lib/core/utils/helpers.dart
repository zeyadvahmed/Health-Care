// ============================================================
// helpers.dart
// General utility functions used across the app.
//
// Usage:
//   Helpers.formatDateTime(session.startTime)
//   Helpers.kgToLbs(80)
//   Helpers.showSuccessSnackBar(context, 'Workout saved!')
//   Helpers.difficultyColor('beginner')
//
// Rules:
//   - Only put functions here that are used in 2+ screens
//   - No UI widgets — only logic and calculations
//   - No Firebase or SQLite calls — pure Dart only
//   - Always use AppColors — never raw Color() values
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class Helpers {

  // ----------------------------------------------------------
  // formatDateTime()
  // Returns a human-readable date+time string.
  // Example: "27 May 2026, 9:41 AM"
  // ----------------------------------------------------------
  static String formatDateTime(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h  = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final m  = date.minute.toString().padLeft(2, '0');
    final ap = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}, $h:$m $ap';
  }

  // ----------------------------------------------------------
  // timeAgo()
  // Returns elapsed time as HH:MM:SS string.
  // Used in ActiveSessionScreen timer display.
  // ----------------------------------------------------------
  static String timeAgo(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    final int hours   = difference.inHours;
    final int minutes = difference.inMinutes.remainder(60);
    final int seconds = difference.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  // ----------------------------------------------------------
  // getGreeting()
  // Returns time-appropriate greeting string.
  // Used in HomeScreen header.
  // ----------------------------------------------------------
  static String getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ----------------------------------------------------------
  // kgToLbs() / lbsToKg()
  // Weight unit conversions. Used in AddExerciseScreen toggle.
  // ----------------------------------------------------------
  static double kgToLbs(double kg) {
    return double.parse((kg * 2.20462).toStringAsFixed(1));
  }

  static double lbsToKg(double lbs) {
    return double.parse((lbs * 0.453592).toStringAsFixed(1));
  }

  // ----------------------------------------------------------
  // getMoodIcon()
  // Returns the correct icon for a mood string.
  // Used in MoodSelector and HomeScreen mood card.
  // ----------------------------------------------------------
  static IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':    return Icons.sentiment_very_satisfied;
      case 'calm':     return Icons.self_improvement;
      case 'tired':    return Icons.bedtime;
      case 'stressed': return Icons.bolt;
      default:         return Icons.sentiment_neutral;
    }
  }

  // ----------------------------------------------------------
  // showSuccessSnackBar()
  // Green floating snackbar for successful operations.
  // ----------------------------------------------------------
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(message),
        backgroundColor: AppColors.success,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // showErrorSnackBar()
  // Red floating snackbar for failed operations.
  // duration: 3s — longer than success so user can read it.
  // ----------------------------------------------------------
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(message),
        backgroundColor: AppColors.error,
        behavior:        SnackBarBehavior.floating,
        duration:        const Duration(seconds: 3),
      ),
    );
  }

  // ----------------------------------------------------------
  // difficultyColor()
  // Returns the correct AppColors constant for a difficulty string.
  // Used in workout cards, exercise tiles, and difficulty badges.
  //
  // RULE: always use AppColors — never raw Color() values here.
  // ----------------------------------------------------------
  static Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':     return AppColors.success;  // green
      case 'intermediate': return AppColors.warning;  // orange
      case 'expert':       return AppColors.error;    // red
      default:             return AppColors.steelColor; // blue fallback
    }
  }
}

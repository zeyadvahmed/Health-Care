// ============================================================
// helpers.dart
// General utility functions used across the app.
//
// Usage:
//   Helpers.formatDateTime(session.startTime)
//   Helpers.kgToLbs(80)
//   Helpers.showSuccessSnackBar(context, 'Workout saved!')
//
// Rules:
//   - Only put functions here that are used in 2+ screens
//   - No UI widgets — only logic and calculations
//   - No Firebase or SQLite calls — pure Dart only
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class Helpers {

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, h:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    final int hours = difference.inHours;
    final int minutes = difference.inMinutes.remainder(60);
    final int seconds = difference.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  static String getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static double kgToLbs(double kg) {
    return double.parse((kg * 2.20462).toStringAsFixed(1));
  }

  static double lbsToKg(double lbs) {
    return double.parse((lbs * 0.453592).toStringAsFixed(1));
  }

  static IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':    return Icons.sentiment_very_satisfied;
      case 'calm':     return Icons.self_improvement;
      case 'tired':    return Icons.bedtime;
      case 'stressed': return Icons.bolt;
      default:         return Icons.sentiment_neutral;
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    // Red snackbar for failed operations.
    // Used in: after failed save, failed sync, validation errors, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
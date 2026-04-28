// ============================================================
// level_up_dialog.dart
// lib/shared/widgets/misc/level_up_dialog.dart
//
// PURPOSE:
//   Celebration dialog shown in activity_screen when the user
//   reaches a new level after completing a workout.
//
// WHY STATELESSWIDGET:
//   The data (newLevel, xpEarned) is fixed when the dialog opens.
//   Nothing inside the dialog changes — it just displays and waits
//   for the user to tap Collect.
//
// HOW IT IS TRIGGERED:
//   activity_controller exposes 'didLevelUp' bool.
//   activity_screen checks this in initState and after loading.
//   When didLevelUp=true, showDialog() is called with this widget.
//   After Collect is tapped, didLevelUp is reset to false.
//
// USAGE:
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => LevelUpDialog(
//       newLevel: 3,
//       xpEarned: 100,
//       onCollect: () {
//         Navigator.pop(context);
//         controller.resetLevelUp();
//       },
//     ),
//   );
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
import '../buttons/custom_button.dart';

class LevelUpDialog extends StatelessWidget {
  // The level the user just reached
  final int newLevel;

  // XP earned from the workout that triggered the level up
  final int xpEarned;

  // Called when user taps Collect — closes dialog + resets flag
  final VoidCallback onCollect;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.xpEarned,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Celebration icon ────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),

            // ── Level up headline ───────────────────────────
            Text(
              'Level Up!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ── New level display ───────────────────────────
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'You reached '),
                  TextSpan(
                    text: 'Level $newLevel',
                    style: TextStyle(
                      color: AppColors.steelColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── XP earned badge ─────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.steelColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.steelColor.withOpacity(0.4)),
              ),
              child: Text(
                '+$xpEarned XP earned',
                style: TextStyle(
                  color: AppColors.steelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Collect button ──────────────────────────────
            CustomButton(
              label: 'Collect',
              onPressed: onCollect,
            ),
          ],
        ),
      ),
    );
  }
}
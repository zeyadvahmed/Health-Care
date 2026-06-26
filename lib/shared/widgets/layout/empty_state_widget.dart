// ============================================================
// empty_state_widget.dart
// lib/shared/widgets/layout/empty_state_widget.dart
//
// Reusable empty state display used when a list has no items.
//
// Usage:
//   EmptyStateWidget(
//     icon:        Icons.fitness_center_outlined,
//     message:     'No workouts yet.\nTap + to create one.',
//     actionLabel: 'Create Workout',   // optional
//     onAction:    _navigateToCreate,  // optional
//   )
//
// Rules:
//   - actionLabel and onAction are both optional but must
//     be provided together — one without the other is ignored
//   - AppColors only — never raw Color()
//   - withValues(alpha:) — withOpacity() is deprecated
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
class EmptyStateWidget extends StatelessWidget {
  // Icon shown above the message.
  final IconData icon;

  // Main message text — supports '\n' for line breaks.
  final String message;

  // Optional button label. Only shown when onAction is also set.
  final String? actionLabel;

  // Optional button callback. Only shown when actionLabel is set.
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.steelColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.steelColor.withValues(alpha: 0.5),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            // Optional action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.steelColor.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: AppColors.steelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

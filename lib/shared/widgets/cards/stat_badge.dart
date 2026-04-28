// ============================================================
// stat_badge.dart
// lib/shared/widgets/cards/stat_badge.dart
//
// PURPOSE:
//   Small stat card showing one number with an icon and label.
//   Used in 2x2 grids on summary and overview screens.
//
// USED IN:
//   workout_summary_screen  — Duration, Volume, Exercises, Calories
//   workout_overview_screen — exercise count, estimated duration
//   progress_screen         — this week / total workout counts
//
// PARAMETERS:
//   label — stat name shown below value e.g. "Duration"
//   value — the number/text shown prominently e.g. "45 min"
//   icon  — icon shown above value
//   color — accent color for icon and top border
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatBadge({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.8),
        // Subtle colored top border as accent
        // Achieved by wrapping in another container below
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Icon in colored circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),

          // Value — the main number shown prominently
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),

          // Label — small descriptor below the value
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
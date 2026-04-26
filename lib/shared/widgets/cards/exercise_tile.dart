// ============================================================
// exercise_tile.dart
// lib/shared/widgets/cards/exercise_tile.dart
//
// PURPOSE:
//   Compact list tile for one exercise inside a workout.
//   Used in: create_workout_screen, workout_overview_screen,
//            workout_session_screen.
//
// NOTE ON exerciseName:
//   The tile receives exerciseName as a String parameter.
//   The parent screen is responsible for resolving the name
//   from the exerciseId before passing it here.
//   This keeps the widget stateless and fast.
//
// RULES:
//   - StatelessWidget — all data passed as parameters
//   - Use AppColors
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ExerciseTile extends StatelessWidget {
  // Exercise name (resolved from exerciseId by parent)
  final String exerciseName;

  // Muscle group string e.g. "chest" or "chest|shoulders"
  final String muscleGroup;

  final int sets;
  final int reps;

  // null = bodyweight exercise
  final double? weight;

  // Called when user taps the edit icon
  final VoidCallback onEdit;

  // Called when user taps the delete icon
  final VoidCallback onDelete;

  const ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    this.weight,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fitness_center,
                color: AppColors.steelColor, size: 18),
          ),
          const SizedBox(width: 10),

          // Name + muscle group + info chips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Info chips row
                Row(
                  children: [
                    // Muscle group
                    _chip(
                      // Take only first muscle if pipe-delimited
                      muscleGroup.split('|').first,
                      AppColors.textSecondary,
                      AppColors.cardBackground,
                    ),
                    const SizedBox(width: 6),
                    // Sets × Reps chip
                    _chip(
                      '$sets × $reps',
                      AppColors.steelColor,
                      AppColors.steelColor.withOpacity(0.15),
                    ),
                    const SizedBox(width: 6),
                    // Weight chip or Bodyweight
                    _chip(
                      weight != null
                          ? '${weight!.toStringAsFixed(1)} kg'
                          : 'BW',
                      Colors.white70,
                      Colors.white.withOpacity(0.08),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: AppColors.steelColor, size: 18),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // Delete button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // _chip()
  // Small rounded label used for muscle group, sets×reps, weight.
  // ----------------------------------------------------------
  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
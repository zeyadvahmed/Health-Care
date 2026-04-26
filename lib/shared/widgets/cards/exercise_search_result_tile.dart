// ============================================================
// exercise_search_result_tile.dart
// lib/shared/widgets/cards/exercise_search_result_tile.dart
//
// PURPOSE:
//   Displays one exercise in search results.
//   Used in: exercise_search_screen results list and in the
//            dropdown overlay of ExerciseSearchField.
//
// RULES:
//   - StatelessWidget — fixed data, no state
//   - Show image placeholder if imageUrl is empty or fails
//   - Truncate first instruction to 2 lines max
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/exercise_model.dart';

class ExerciseSearchResultTile extends StatelessWidget {
  final ExerciseModel exercise;

  // Called when user taps the tile — selects this exercise
  final VoidCallback onTap;

  const ExerciseSearchResultTile({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get first instruction line for description preview
    final description = exercise.instructions.isNotEmpty
        ? exercise.instructions.first
        : 'No description available.';

    // Get first primary muscle for display
    final muscle = exercise.primaryMuscles.isNotEmpty
        ? exercise.primaryMuscles.first
        : exercise.category;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ── Exercise image ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: exercise.imageUrl.isNotEmpty
                    ? Image.asset(
                        'assets/exercises/${exercise.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),

            // ── Text content ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name — bold
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Primary muscle group — grey
                  Text(
                    muscle,
                    style: TextStyle(
                      color: AppColors.steelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // First instruction line — truncated
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron arrow
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.sparkColor,
      child: const Icon(Icons.fitness_center,
          color: Colors.white38, size: 28),
    );
  }
}
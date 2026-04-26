// ============================================================
// workout_card.dart
// lib/shared/widgets/cards/workout_card.dart
//
// PURPOSE:
//   Displays a workout in two distinct visual styles.
//
// TWO STYLES:
//   isPredefined=true  → Image card (used in predefined section)
//     - Full background image from workout.imageUrl
//     - Difficulty badge overlay in top-right corner
//     - Workout name and description below image
//     - Start button and View Details button at bottom
//
//   isPredefined=false → List tile (used in My Workouts section)
//     - Fitness center icon on the left
//     - Name bold, difficulty chip and duration below
//     - View Details and Edit buttons on the right
//
// RULES:
//   - StatelessWidget — all data passed as parameters
//   - Use AppColors — never hardcode colors
//   - Difficulty color from Helpers.difficultyColor()
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/workout_model.dart';
import '../buttons/custom_button.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final bool isPredefined;

  // Predefined only — tapping Start creates a session
  final VoidCallback? onStart;

  // Both styles — navigates to workout_overview_screen
  final VoidCallback onViewDetails;

  // My Workouts only — navigates to edit mode
  final VoidCallback? onEdit;

  // My Workouts only — shows confirm dialog then deletes
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.isPredefined,
    this.onStart,
    required this.onViewDetails,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return isPredefined
        ? _buildPredefinedCard(context)
        : _buildMyWorkoutCard(context);
  }

  // ----------------------------------------------------------
  // _buildPredefinedCard()
  // Image card style for seeded/predefined workouts.
  // Shows background image, difficulty badge, name, and buttons.
  // ----------------------------------------------------------
  Widget _buildPredefinedCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardBackground,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Background image area ─────────────────────────
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Workout image or placeholder
                workout.imageUrl != null
                    ? Image.network(
                        workout.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),

                // Dark gradient overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),

                // Difficulty badge in top-right corner
                Positioned(
                  top: 10,
                  right: 10,
                  child: _difficultyBadge(),
                ),
              ],
            ),
          ),

          // ── Card body ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout name
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Duration
                const SizedBox(height: 4),
                Text(
                  '${workout.durationMinutes} min',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                // Start + View Details buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Start',
                        onPressed: onStart,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        label: 'Details',
                        isOutlined: true,
                        onPressed: onViewDetails,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // _buildMyWorkoutCard()
  // List tile style for user-created workouts.
  // ----------------------------------------------------------
  Widget _buildMyWorkoutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Fitness icon circle on the left
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.steelColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Workout name + meta info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Difficulty chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Helpers.difficultyColor(workout.difficulty)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        workout.difficulty,
                        style: TextStyle(
                          color: Helpers.difficultyColor(
                              workout.difficulty),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Duration
                    Text(
                      '${workout.durationMinutes} min',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons on the right
          IconButton(
            icon: const Icon(Icons.visibility_outlined,
                color: Colors.white54, size: 20),
            onPressed: onViewDetails,
            tooltip: 'View Details',
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: AppColors.steelColor, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // _imagePlaceholder()
  // Shown when imageUrl is null or fails to load.
  // ----------------------------------------------------------
  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.sparkColor,
      child: const Center(
        child: Icon(Icons.fitness_center,
            color: Colors.white38, size: 40),
      ),
    );
  }

  // ----------------------------------------------------------
  // _difficultyBadge()
  // Small colored pill overlay for the predefined card image.
  // ----------------------------------------------------------
  Widget _difficultyBadge() {
    final color = Helpers.difficultyColor(workout.difficulty);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        workout.difficulty[0].toUpperCase() +
            workout.difficulty.substring(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
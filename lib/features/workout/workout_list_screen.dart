// ============================================================
// workouts_list_screen.dart
// lib/features/workout/workouts_list_screen.dart
//
// Shows two sections:
//   1. Predefined Workouts  → horizontal scrolling image cards
//   2. My Workouts          → vertical list of user-created cards
//
// State management: BlocConsumer<WorkoutController, WorkoutState>
//   - listenWhen: only passes WorkoutError states to listener
//   - listener  : shows error snackbar
//   - builder   : renders loading / list / empty states
//
// Navigation:
//   FAB         → CreateWorkoutScreen  (Navigator.push — PASS DATA)
//   View Details→ WorkoutOverviewScreen (Navigator.push — PASS DATA, commented until built)
//   Edit        → CreateWorkoutScreen with existingWorkout (Navigator.push — PASS DATA)
//   Start       → WorkoutOverviewScreen (Navigator.push — PASS DATA, commented until built)
//
// RELOAD STRATEGY:
//   _navigateToCreate and _navigateToEdit do NOT call loadWorkouts()
//   on return. WorkoutController.saveWorkout() already updates the
//   in-memory cache and emits WorkoutLoaded — a second loadWorkouts()
//   call would cause a visible Loading → Loaded flicker for no reason.
//   The BlocConsumer builder re-renders automatically when the cubit
//   emits the new WorkoutLoaded state from saveWorkout().
//
// userId: optional, defaults to '' until AuthCubit is wired up.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/workout_model.dart';
import '../../shared/widgets/buttons/custom_button.dart';
import '../../shared/widgets/layout/empty_state_widget.dart';
import 'workout_controller.dart';
import 'workout_state.dart';
import 'create_workout_screen.dart';
// Uncomment when WorkoutOverviewScreen is built:
// import 'workout_overview_screen.dart';

// ── File-level color constants ────────────────────────────────
// TODO: Move into AppColors once the design palette is finalised.
const Color _kCardBg = Color(0xFF0D3358); // card surface
const Color _kPlaceholderBg = Color(0xFF0A2540); // image placeholder

// ─────────────────────────────────────────────────────────────
// WorkoutListScreen
// ─────────────────────────────────────────────────────────────
class WorkoutListScreen extends StatefulWidget {
  // Replace '' with real uid once AuthCubit is wired up.
  final String userId;

  const WorkoutListScreen({super.key, this.userId = ''});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback ensures context.read() is safe on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutController>().loadWorkouts(widget.userId);
    });
  }

  // ── Navigation ────────────────────────────────────────────

  /// Opens CreateWorkoutScreen in create mode.
  /// Does NOT call loadWorkouts() on return — saveWorkout() in the
  /// controller already updates the cache and emits WorkoutLoaded.
  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(userId: widget.userId),
      ),
    );
  }

  /// Opens CreateWorkoutScreen in edit mode with the existing workout.
  /// Same reload strategy as _navigateToCreate().
  void _navigateToEdit(WorkoutModel workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(
          userId: widget.userId,
          existingWorkout: workout,
        ),
      ),
    );
  }

  /// Opens WorkoutOverviewScreen.
  /// Uses Navigator.push (PASS DATA) — never pushNamed.
  /// TODO: uncomment when WorkoutOverviewScreen is built.
  void _navigateToOverview(WorkoutModel workout) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => WorkoutOverviewScreen(
    //       workout: workout,
    //       userId:  widget.userId,
    //     ),
    //   ),
    // );
    Helpers.showSuccessSnackBar(
      context,
      'WorkoutOverviewScreen not built yet.',
    );
  }

  /// Shows a confirmation dialog then calls deleteWorkout().
  void _confirmDelete(WorkoutModel workout) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _kCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Workout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Delete "${workout.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<WorkoutController>().deleteWorkout(
                workout.id,
                widget.userId,
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: _buildAppBar(),
      body: BlocConsumer<WorkoutController, WorkoutState>(
        // Only pass WorkoutError to the listener.
        // WorkoutLoaded and WorkoutLoading are handled purely in
        // the builder — no navigation side-effect needed here.
        listenWhen: (_, current) => current is WorkoutError,
        listener: (context, state) {
          if (state is WorkoutError) {
            Helpers.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is WorkoutLoading || state is WorkoutInitial) {
            return _buildLoading();
          }

          if (state is WorkoutLoaded) {
            final predefined = state.workouts
                .where((w) => w.isPredefined)
                .toList();
            final mine = state.workouts.where((w) => !w.isPredefined).toList();
            return _buildBody(predefined, mine);
          }

          // Any other state (WorkoutSearchResults from a stale search,
          // WorkoutSessionActive etc.) — show loading until next Loaded.
          return _buildLoading();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppColors.steelColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.splashBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        AppStrings.workouts,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Loading ───────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.steelColor,
        strokeWidth: 2.5,
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody(List<WorkoutModel> predefined, List<WorkoutModel> mine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(AppStrings.predefinedWorkouts),
          const SizedBox(height: 12),
          predefined.isEmpty
              ? _predefinedPlaceholder()
              : _buildPredefinedList(predefined),

          const SizedBox(height: 28),

          _sectionHeader(AppStrings.myWorkouts),
          const SizedBox(height: 12),
          mine.isEmpty ? _buildMyWorkoutsEmpty() : _buildMyWorkoutsList(mine),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ── Predefined workouts — horizontal scroll ───────────────
  Widget _buildPredefinedList(List<WorkoutModel> workouts) {
    return SizedBox(
      height: 265,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: workouts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return SizedBox(
            width: 240,
            child: _PredefinedWorkoutCard(
              workout: workout,
              onStart: () => _navigateToOverview(workout),
              onViewDetails: () => _navigateToOverview(workout),
            ),
          );
        },
      ),
    );
  }

  // Shown when predefined workouts haven't been seeded yet.
  Widget _predefinedPlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, color: Colors.white30, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Predefined workouts loading…',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Workouts — vertical list ───────────────────────────
  Widget _buildMyWorkoutsList(List<WorkoutModel> workouts) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return _MyWorkoutCard(
          workout: workout,
          onViewDetails: () => _navigateToOverview(workout),
          onEdit: () => _navigateToEdit(workout),
          onDelete: () => _confirmDelete(workout),
        );
      },
    );
  }

  // Shown when the user has no workouts yet.
  Widget _buildMyWorkoutsEmpty() {
    return EmptyStateWidget(
      message: 'No workouts yet.\nTap + to create your first workout.',
      icon: Icons.fitness_center_outlined,
      actionLabel: 'Create Workout',
      onAction: _navigateToCreate,
    );
  }
}

// ════════════════════════════════════════════════════════════
// _PredefinedWorkoutCard
// Horizontal card for predefined workouts.
// Shows image (or placeholder), difficulty badge, name,
// duration, Start and View Details buttons.
// ════════════════════════════════════════════════════════════
class _PredefinedWorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onStart;
  final VoidCallback onViewDetails;

  const _PredefinedWorkoutCard({
    required this.workout,
    required this.onStart,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ──────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Network image or placeholder
                workout.imageUrl != null && workout.imageUrl!.isNotEmpty
                    ? Image.network(
                        workout.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),

                // Difficulty badge — top left
                Positioned(
                  top: 10,
                  left: 10,
                  child: _DifficultyBadge(difficulty: workout.difficulty),
                ),
              ],
            ),
          ),

          // ── Card body ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        workout.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${workout.durationMinutes} min',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Description (optional)
                if (workout.description != null &&
                    workout.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    workout.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // Start + View Details
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: AppStrings.startButton,
                        onPressed: onStart,
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        label: AppStrings.viewDetails,
                        isOutlined: true,
                        onPressed: onViewDetails,
                        height: 36,
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

  Widget _placeholder() {
    return Container(
      color: _kPlaceholderBg,
      child: const Center(
        child: Icon(Icons.fitness_center, color: Colors.white24, size: 44),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _MyWorkoutCard
// Vertical list tile for user-created workouts.
// Shows icon, name, difficulty chip, duration, action buttons.
// ════════════════════════════════════════════════════════════
class _MyWorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyWorkoutCard({
    required this.workout,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = Helpers.difficultyColor(workout.difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.steelColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Name + difficulty chip + duration
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        workout.difficulty[0].toUpperCase() +
                            workout.difficulty.substring(1),
                        style: TextStyle(
                          color: difficultyColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${workout.durationMinutes} min',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          _iconBtn(Icons.visibility_outlined, Colors.white54, onViewDetails),
          _iconBtn(Icons.edit_outlined, AppColors.steelColor, onEdit),
          _iconBtn(Icons.delete_outline, AppColors.error, onDelete),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _DifficultyBadge
// Pill overlay shown on predefined workout image cards.
// ════════════════════════════════════════════════════════════
class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// exercise_search_screen.dart
// lib/features/workout/exercise_search_screen.dart
//
// Browse and search the full exercise library (873 exercises).
//
// TWO USAGE MODES:
//
//   1. STANDALONE (current) — navigated to from a future
//      "Browse Exercises" button. Returns nothing.
//
//   2. PICKER (future) — navigated to from create_workout_screen
//      instead of AddExerciseScreen. When user selects an exercise,
//      pops with AddExerciseResult so create_workout_screen
//      appends it to its local list.
//
//      To wire this up later:
//        a) Uncomment the preselectedExercise parameter in
//           add_exercise_screen.dart and its initState handling.
//        b) Update create_workout_screen._addExercise() and
//           _editExercise() to navigate here first, then to
//           AddExerciseScreen with preselectedExercise set.
//
// STATE MANAGEMENT:
//   BlocBuilder<WorkoutController, WorkoutState>
//   buildWhen: only rebuilds on WorkoutSearchResults or WorkoutLoading.
//   WorkoutLoaded / WorkoutSessionActive etc. are ignored here.
//
// SEARCH BEHAVIOUR:
//   - On open        → loadAllExercises() (show all 873)
//   - Query typed    → searchExercises(query) on every keystroke
//   - Query cleared  → loadAllExercises() (back to full list)
//   - No results     → EmptyStateWidget
//
// RULES FOLLOWED:
//   - withValues(alpha:) — withOpacity() is deprecated
//   - AppColors only — never raw Color()
//   - primaryMuscles is List<String> — always .join(', ') for display
//   - exerciseId is a raw string — never assume it is readable text
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/exercise_model.dart';
import '../../shared/widgets/layout/empty_state_widget.dart';
import 'workout_controller.dart';
import 'workout_state.dart';
import 'add_exercise_screen.dart';

// ── File-level color constants ────────────────────────────────
// TODO: Move into AppColors once the design palette is finalised.
const Color _kSearchBg  = Color(0xFF082035); // search bar fill
const Color _kDivider   = Color(0xFF0F3D63); // thin line between tiles

// ─────────────────────────────────────────────────────────────
// ExerciseSearchScreen
// ─────────────────────────────────────────────────────────────
class ExerciseSearchScreen extends StatefulWidget {
  // workoutId is passed through to AddExerciseScreen so the
  // returned WorkoutExerciseModel has the correct workoutId set.
  // Stays '' until create_workout_screen passes the real workout id.
  final String workoutId;

  // existingResult is forwarded to AddExerciseScreen in edit mode
  // so the form opens pre-filled. Null in add mode.
  final AddExerciseResult? existingResult;

  const ExerciseSearchScreen({
    super.key,
    this.workoutId    = '',
    this.existingResult,
  });

  @override
  State<ExerciseSearchScreen> createState() =>
      _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode             _searchFocus = FocusNode();

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Load all exercises immediately so the list is populated
    // as soon as the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutController>().loadAllExercises();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Guard flag — prevents _onSearchChanged from firing when
  // _clearSearch() calls _searchCtrl.clear() programmatically.
  bool _clearing = false;

  // ── Search handler ────────────────────────────────────────
  void _onSearchChanged(String query) {
    if (_clearing) return; // skip when clear() triggers onChanged
    if (query.trim().isEmpty) {
      context.read<WorkoutController>().loadAllExercises();
    } else {
      context.read<WorkoutController>().searchExercises(query);
    }
  }

  void _clearSearch() {
    _clearing = true;
    _searchCtrl.clear();
    _clearing = false;
    _searchFocus.requestFocus();
    context.read<WorkoutController>().loadAllExercises();
  }

  // ── Exercise selected ─────────────────────────────────────
  // When a user taps an exercise tile, navigate to AddExerciseScreen
  // with the exercise pre-selected.
  // AddExerciseScreen returns AddExerciseResult via Navigator.pop.
  // We pop that result further back to create_workout_screen.
  Future<void> _onExerciseTapped(ExerciseModel exercise) async {
    final result = await Navigator.push<AddExerciseResult>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExerciseScreen(
          workoutId:      widget.workoutId,
          existingResult: widget.existingResult,
          // Uncomment when preselectedExercise is wired in AddExerciseScreen:
          // preselectedExercise: exercise,
        ),
      ),
    );

    // If user saved, pop this screen too — passing the result back
    // to create_workout_screen which awaits it.
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar — always visible, not scrollable
          _buildSearchBar(),
          const SizedBox(height: 4),

          // Results — fills remaining height
          Expanded(
            child: BlocBuilder<WorkoutController, WorkoutState>(
              // Only rebuild for search result and loading states.
              // WorkoutLoaded (from saveWorkout), WorkoutSessionActive,
              // etc. are irrelevant here and must not trigger a rebuild.
              buildWhen: (_, current) =>
                  current is WorkoutSearchResults ||
                  current is WorkoutLoading,
              builder: (context, state) {
                if (state is WorkoutLoading) {
                  return _buildLoading();
                }

                if (state is WorkoutSearchResults) {
                  if (state.results.isEmpty) {
                    return _buildEmpty();
                  }
                  return _buildResults(state.results);
                }

                // Initial state before loadAllExercises() fires.
                return _buildLoading();
              },
            ),
          ),
        ],
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
        AppStrings.exercisesLabel,
        style: TextStyle(
          color:      Colors.white,
          fontSize:   18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Search bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller:  _searchCtrl,
        focusNode:   _searchFocus,
        onChanged:   _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText:  'Search exercises…',
          hintStyle: TextStyle(
            color:    Colors.white.withValues(alpha: 0.35),
            fontSize: 14,
          ),
          filled:    true,
          fillColor: _kSearchBg,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.45),
            size:  20,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchCtrl,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: _clearSearch,
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 18,
                ),
              );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical:   13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: AppColors.steelColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color:       AppColors.steelColor,
        strokeWidth: 2.5,
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmpty() {
    final hasQuery = _searchCtrl.text.trim().isNotEmpty;
    return EmptyStateWidget(
      icon:    Icons.fitness_center_outlined,
      message: hasQuery
          ? 'No exercises found for "${_searchCtrl.text.trim()}".\nTry a different search term.'
          : AppStrings.noDataYet,
    );
  }

  // ── Results list ──────────────────────────────────────────
  Widget _buildResults(List<ExerciseModel> exercises) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount:       exercises.length,
      separatorBuilder: (_, __) => Divider(
        color:   _kDivider,
        height:  1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _ExerciseTile(
          exercise:  exercise,
          onTap:     () => _onExerciseTapped(exercise),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
// _ExerciseTile
// One row in the exercise results list.
//
// Shows:
//   - Exercise name (bold white)
//   - Primary muscles (join(', ') — required by project rules)
//   - Level badge chip
//   - Equipment tag
//   - Category chip on the right
//
// NOTE: This is a private inline implementation.
//   When lib/shared/widgets/cards/exercise_search_result_tile.dart
//   is built, replace this class with:
//     import '../../shared/widgets/cards/exercise_search_result_tile.dart';
//   and use ExerciseSearchResultTile instead.
// ════════════════════════════════════════════════════════════
class _ExerciseTile extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback  onTap;

  const _ExerciseTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // primaryMuscles is List<String> — always join(', ') for display.
    // NEVER access it as a plain String directly.
    final muscles = exercise.primaryMuscles.isNotEmpty
        ? exercise.primaryMuscles.join(', ')
        : 'General';

    final levelColor = Helpers.difficultyColor(
      exercise.level.toLowerCase(),
    );

    return InkWell(
      onTap:           onTap,
      borderRadius:    BorderRadius.circular(12),
      splashColor:     AppColors.steelColor.withValues(alpha: 0.08),
      highlightColor:  AppColors.steelColor.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // ── Exercise icon ──────────────────────────────
            Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.steelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppColors.steelColor,
                size:  20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + muscles + tags ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Muscles subtitle
                  Text(
                    muscles,
                    style: TextStyle(
                      color:    Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Level + equipment chips
                  Row(
                    children: [
                      if (exercise.level.isNotEmpty)
                        _chip(
                          exercise.level[0].toUpperCase() +
                              exercise.level.substring(1),
                          levelColor,
                          levelColor.withValues(alpha: 0.15),
                        ),
                      if (exercise.level.isNotEmpty &&
                          exercise.equipment.isNotEmpty)
                        const SizedBox(width: 6),
                      if (exercise.equipment.isNotEmpty)
                        _chip(
                          exercise.equipment,
                          Colors.white54,
                          Colors.white.withValues(alpha: 0.07),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Category chip ──────────────────────────────
            if (exercise.category.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _chip(
                  exercise.category,
                  AppColors.steelColor,
                  AppColors.steelColor.withValues(alpha: 0.12),
                ),
              ),

            // ── Arrow ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.25),
                size:  14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      textColor,
          fontSize:   10,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
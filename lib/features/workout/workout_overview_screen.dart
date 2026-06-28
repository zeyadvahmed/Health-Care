// ============================================================
// workout_overview_screen.dart
// lib/features/workout/workout_overview_screen.dart
//
// Displays one workout's details before the user starts it.
//
// WHAT IT SHOWS:
//   - Workout name + formatted date + UPCOMING badge
//   - "Ready to start?" info card with estimated duration
//   - Exercise list with Edit / Delete per exercise
//   - Start Workout button at the bottom
//
// NAVIGATION (all PASS DATA — never pushNamed):
//   Incoming : Navigator.push from WorkoutsListScreen
//              receives WorkoutModel + userId
//   Edit exercise → CreateWorkoutScreen(existingWorkout: workout)
//   Start Workout → ActiveSessionScreen (TODO: uncomment when built)
//                   calls startSession() on WorkoutController
//
// STATE MANAGEMENT:
//   BlocConsumer<WorkoutController, WorkoutState>
//     listenWhen: WorkoutLoading → WorkoutLoaded (save/delete)
//                 WorkoutLoading → WorkoutError   (error)
//                 WorkoutSessionActive             (start)
//   - Exercises are loaded in initState via getExercisesForWorkout()
//     and resolveExerciseNames() — never in build()
//   - deleteExercise() emits WorkoutLoading then WorkoutLoaded
//   - startSession() emits WorkoutSessionActive
//
// RULES FOLLOWED:
//   - resolveExerciseNames() ONLY in initState
//   - withValues(alpha:) — withOpacity() is deprecated
//   - AppColors only — never raw Color()
//   - AppStrings for all UI strings
//   - primaryMuscles is List<String> → always .join(', ')
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/workout_model.dart';
import 'workout_controller.dart';
import 'workout_state.dart';
import 'workout_session_screen.dart'; // provides ResolvedExercise
import 'create_workout_screen.dart';

// ── File-level color constants ─────────────────────────────────
// TODO: Move into AppColors once design palette is finalised.
const Color _kCardBg = Color(0xFF0D3358); // card / tile background
const Color _kInfoCardBg = Color(0xFF0A2540); // "Ready to start?" card

// ─────────────────────────────────────────────────────────────
// WorkoutOverviewScreen
// ─────────────────────────────────────────────────────────────
class WorkoutOverviewScreen extends StatefulWidget {
  final WorkoutModel workout;
  final String userId;

  const WorkoutOverviewScreen({
    super.key,
    required this.workout,
    this.userId = '',
  });

  @override
  State<WorkoutOverviewScreen> createState() => _WorkoutOverviewScreenState();
}

class _WorkoutOverviewScreenState extends State<WorkoutOverviewScreen> {
  // Resolved exercise list — populated in initState.
  // Local mutable copy of the workout — refreshed from SQLite
  // after _editWorkout() so name/duration update without popping.
  late WorkoutModel _workout;

  // Never rebuilt from SQLite in build().
  List<ResolvedExercise> _exercises = [];

  // Loading state for initState data fetch only.
  // Distinct from BlocBuilder state — this controls the
  // initial skeleton loader before exercises are ready.
  bool _loadingExercises = true;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Initialise local mutable copy from the incoming param.
    _workout = widget.workout;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  // ── Load exercises from SQLite ─────────────────────────────
  // Called once in initState. resolveExerciseNames() is called
  // here — NEVER in build() or inside a ListView.builder().
  Future<void> _loadExercises() async {
    final ctrl = context.read<WorkoutController>();

    final raw = await ctrl.getExercisesForWorkout(_workout.id);

    // resolveExerciseNames() maps exerciseId → ExerciseModel.
    // CRITICAL: only called here in initState postFrameCallback.
    final nameMap = await ctrl.resolveExerciseNames(raw);

    if (!mounted) return;
    setState(() {
      _exercises = raw.map((we) {
        final ex = nameMap[we.exerciseId];
        return ResolvedExercise(
          model: we,
          displayName: ex?.name ?? we.exerciseId,
          // primaryMuscles is List<String> — always join(', ')
          muscleGroup: ex?.primaryMuscles.join(', ') ?? '',
        );
      }).toList();
      _loadingExercises = false;
    });
  }

  // ── Computed helpers ──────────────────────────────────────
  String get _formattedDate {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = DateTime.now();
    // DateTime.weekday: 1=Mon … 7=Sun
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String get _estimatedTime {
    final h = _workout.durationMinutes ~/ 60;
    final m = _workout.durationMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  // ── Start workout ─────────────────────────────────────────
  // Calls startSession() which inserts a session row into SQLite
  // and emits WorkoutSessionActive. BlocConsumer listener then
  // navigates to ActiveSessionScreen.
  void _startWorkout() {
    context.read<WorkoutController>().startSession(_workout.id, widget.userId);
  }

  // ── Edit workout ──────────────────────────────────────────
  // Opens CreateWorkoutScreen in edit mode. On return,
  // reloads exercises to reflect any changes.
  Future<void> _editWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(
          userId: widget.userId,
          existingWorkout: _workout,
        ),
      ),
    );
    if (!mounted) return;
    // Reload fresh workout from SQLite so name/duration update
    // on this screen without the user having to pop and re-open.
    final updated = await context.read<WorkoutController>().getWorkoutById(
      _workout.id,
    );
    if (!mounted) return;
    setState(() {
      if (updated != null) _workout = updated;
      _loadingExercises = true;
    });
    await _loadExercises();
  }

  // ── Delete single exercise ────────────────────────────────
  // Removes one exercise from the workout. Shows confirm dialog
  // then deletes via LocalWorkoutService (through controller).
  void _confirmDeleteExercise(int index) {
    final ex = _exercises[index];
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _kCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Exercise',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove "${ex.displayName}" from this workout?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _deleteExercise(index);
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // Performs the actual exercise deletion from SQLite.
  // Uses deleteWorkoutExercise(id) — removes a single exercise row
  // by its own id, NOT deleteExercisesForWorkout which wipes ALL.
  Future<void> _deleteExercise(int index) async {
    final we = _exercises[index].model;
    try {
      await context.read<WorkoutController>().deleteSingleExercise(
        we.id,
        widget.userId,
      );
      if (mounted) {
        setState(() => _exercises.removeAt(index));
      }
    } catch (_) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Could not remove exercise.');
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutController, WorkoutState>(
      // Only react to transitions this screen triggered:
      //   Loading → Loaded  : save/delete completed
      //   Loading → Error   : operation failed
      //   Any → SessionActive : startSession() completed
      listenWhen: (previous, current) =>
          (previous is WorkoutLoading &&
              (current is WorkoutLoaded || current is WorkoutError)) ||
          current is WorkoutSessionActive,
      listener: (context, state) {
        if (state is WorkoutError) {
          Helpers.showErrorSnackBar(context, state.message);
        }
        if (state is WorkoutSessionActive) {
          // Navigate to ActiveSessionScreen — PASS DATA.
          // _exercises is List<ResolvedExercise> — pass directly.
          // Do NOT call .map((e) => e.model) — that produces
          // List<WorkoutExerciseModel> which is the wrong type.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutSessionScreen(
                session: state.activeSession,
                workout: widget.workout,
                exercises: _exercises,
                userId: widget.userId,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state is WorkoutLoading;

        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              _buildBody(),
              // Overlay while startSession() or delete is running
              if (isBusy)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.steelColor,
                    ),
                  ),
                ),
            ],
          ),
          // bottomNavigationBar shifts up with keyboard
          bottomNavigationBar: _buildStartBar(isBusy),
        );
      },
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
        AppStrings.workoutOverview,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // Edit workout button — top right
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          onPressed: _editWorkout,
          tooltip: 'Edit Workout',
        ),
      ],
    );
  }

  // ── Scrollable body ───────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildExerciseListSection(),
        ],
      ),
    );
  }

  // ── Header: name + date + badge ───────────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _workout.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formattedDate,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // UPCOMING badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.steelColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.steelColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            AppStrings.upcomingBadge,
            style: TextStyle(
              color: AppColors.steelColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── "Ready to start?" info card ───────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kInfoCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.steelColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.timer_outlined,
              color: AppColors.steelColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.readyToStart,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Estimated $_estimatedTime · '
                  '${_exercises.length} '
                  '${_exercises.length == 1 ? 'exercise' : 'exercises'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Exercise list section ─────────────────────────────────
  Widget _buildExerciseListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          '${AppStrings.exerciseList} (${_exercises.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Loading skeleton
        if (_loadingExercises) _buildLoadingSkeleton(),

        // Empty state
        if (!_loadingExercises && _exercises.isEmpty) _buildEmptyExercises(),

        // Exercise tiles
        if (!_loadingExercises && _exercises.isNotEmpty)
          ...List.generate(_exercises.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExerciseTile(
                resolved: _exercises[i],
                onEdit: () => _editWorkout(),
                onDelete: () => _confirmDeleteExercise(i),
              ),
            );
          }),
      ],
    );
  }

  // Skeleton rows shown while exercises are loading from SQLite.
  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(3, (_) {
        return Container(
          height: 78,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Shown when workout has no exercises at all.
  Widget _buildEmptyExercises() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_outlined, color: Colors.white24, size: 32),
          const SizedBox(height: 10),
          Text(
            'No exercises in this workout.\nTap edit to add some.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom start bar ──────────────────────────────────────
  Widget _buildStartBar(bool isBusy) {
    return Container(
      color: AppColors.splashBackground,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isBusy || _exercises.isEmpty ? null : _startWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.steelColor,
            disabledBackgroundColor: AppColors.steelColor.withValues(
              alpha: 0.35,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  AppStrings.startWorkout,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _ExerciseTile
// One exercise row in the overview list.
// Shows: name, muscles, sets × reps, weight/BW, rest.
// Edit opens CreateWorkoutScreen. Delete shows confirm dialog.
// ════════════════════════════════════════════════════════════
class _ExerciseTile extends StatelessWidget {
  final ResolvedExercise resolved;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseTile({
    required this.resolved,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final we = resolved.model;

    // "4 sets × 8-10 reps . 90s rest"
    final setRep = '${we.sets} sets × ${we.reps} reps';
    final rest = '${we.restSeconds}s rest';
    final weight = we.weight != null
        ? '${we.weight!.toStringAsFixed(1)} kg'
        : 'Bodyweight';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.steelColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),

          // Name + muscle + detail row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolved.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (resolved.muscleGroup.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    resolved.muscleGroup,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 7),
                // Detail chips row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _chip(
                      setRep,
                      AppColors.steelColor,
                      AppColors.steelColor.withValues(alpha: 0.13),
                    ),
                    _chip(
                      weight,
                      Colors.white60,
                      Colors.white.withValues(alpha: 0.07),
                    ),
                    _chip(
                      rest,
                      Colors.white54,
                      Colors.white.withValues(alpha: 0.07),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit + Delete buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionBtn(
                Icons.edit_outlined,
                AppStrings.editButton,
                AppColors.steelColor,
                onEdit,
              ),
              const SizedBox(height: 6),
              _actionBtn(
                Icons.delete_outline,
                AppStrings.delete,
                AppColors.error,
                onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// workout_session_screen.dart
// lib/features/workout/workout_session_screen.dart
//
// Runs the live workout session.
//
// WHAT IT SHOWS:
//   - Workout name in AppBar
//   - Running timer (counts up from 0) + Pause/Resume + Finish
//   - Workout Progress bar (completed sets / total sets)
//   - Expandable exercise cards, each with a set row table:
//       Set# | Reps | Status (checkbox)
//   - RestTimerDialog appears after every checked set
//
// STATE STRATEGY (intentional — no BlocBuilder here):
//   The timer ticks every second and checkboxes fire on every
//   tap — rebuilding via Cubit for those would cause unnecessary
//   overhead and flicker. Local setState handles:
//     - timer seconds
//     - pause/resume state
//     - which sets are checked (_completedSets)
//     - which exercise cards are expanded (_expanded)
//     - accumulated session logs (_logs)
//
//   BlocConsumer is used for ONE purpose only:
//     listenWhen: Loading → Loaded  (finishSession completed)
//     On WorkoutLoaded: navigate to WorkoutSummaryScreen.
//     On WorkoutError:  show snackbar.
//
// NAVIGATION (PASS DATA — never pushNamed):
//   Incoming : Navigator.push from WorkoutOverviewScreen
//              receives WorkoutSessionModel, WorkoutModel,
//              List<ResolvedExercise>, userId
//   Finish   → WorkoutSummaryScreen (Navigator.pushReplacement
//              so back button doesn't return to active session)
//
// TIMER RULES:
//   - Timer.periodic created in initState
//   - MUST be cancelled in dispose() — memory leak otherwise
//   - Pausing sets _isPaused=true, timer keeps running but
//     seconds don't increment — preserves accuracy
//
// RULES FOLLOWED:
//   - withValues(alpha:) — withOpacity() is deprecated
//   - AppColors only — never raw Color()
//   - AppStrings for all UI text
//   - primaryMuscles is List<String> → always .join(', ')
//   - Timer always cancelled in dispose()
//   - logSet() does NOT emit state — setState used for checkboxes
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/shared/widgets/cards/rest_timer_dialog.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/workout_exercise_model.dart';
import '../../data/models/session_log_model.dart';
import 'workout_controller.dart';
import 'workout_state.dart';
import 'workout_summary_screen.dart';

// ── File-level color constants ─────────────────────────────────
// TODO: Move into AppColors once design palette is finalised.
const Color _kCardBg = Color(0xFF0D3358); // exercise card background
const Color _kActiveRow = Color(0xFF0F3D63); // highlighted active set row

// ─────────────────────────────────────────────────────────────
// ResolvedExercise
// Shared data class used by both WorkoutOverviewScreen and
// WorkoutSessionScreen. Carries the model plus display strings
// so resolveExerciseNames() is never called more than once.
//
// Defined here (public) so WorkoutOverviewScreen can import it
// and pass instances to WorkoutSessionScreen without a type error.
// ─────────────────────────────────────────────────────────────
class ResolvedExercise {
  final WorkoutExerciseModel model;
  final String displayName;
  final String muscleGroup;

  const ResolvedExercise({
    required this.model,
    required this.displayName,
    required this.muscleGroup,
  });
}

// ─────────────────────────────────────────────────────────────
// _SetKey
// Unique identifier for a single set within a session.
// Used as key in _completedSets map.
// ─────────────────────────────────────────────────────────────
class _SetKey {
  final String exerciseId;
  final int setNumber;

  const _SetKey(this.exerciseId, this.setNumber);

  @override
  bool operator ==(Object other) =>
      other is _SetKey &&
      other.exerciseId == exerciseId &&
      other.setNumber == setNumber;

  @override
  int get hashCode => Object.hash(exerciseId, setNumber);
}

// ─────────────────────────────────────────────────────────────
// WorkoutSessionScreen
// ─────────────────────────────────────────────────────────────
class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutSessionModel session;
  final WorkoutModel workout;
  final List<ResolvedExercise> exercises;
  final String userId;

  const WorkoutSessionScreen({
    super.key,
    required this.session,
    required this.workout,
    required this.exercises,
    this.userId = '',
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  // ── Timer state ───────────────────────────────────────────
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;

  // ── Session state ─────────────────────────────────────────
  // Key: _SetKey(exerciseId, setNumber) — Value: SessionLogModel
  final Map<_SetKey, SessionLogModel> _completedSets = {};

  // Guard flag — prevents double-tap while logSet() is awaiting.
  // Set to true at the start of _onSetTapped, false at the end.
  bool _processing = false;

  // Which exercise card indices are expanded.
  late List<bool> _expanded;

  // Accumulated logs passed to finishSession().
  List<SessionLogModel> get _logs => _completedSets.values.toList();

  // ── Computed helpers ──────────────────────────────────────
  int get _totalSets =>
      widget.exercises.fold(0, (sum, e) => sum + e.model.sets);

  int get _completedSetCount => _completedSets.length;

  double get _progressValue =>
      _totalSets == 0 ? 0 : (_completedSetCount / _totalSets).clamp(0.0, 1.0);

  String get _timerText {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Expand the first exercise card by default.
    _expanded = List.generate(widget.exercises.length, (i) => i == 0);
    _startTimer();
  }

  @override
  void dispose() {
    // CRITICAL: always cancel Timer to prevent memory leaks.
    _timer.cancel();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  // ── Set checkbox tap ──────────────────────────────────────
  // Called when the user taps a set checkbox.
  // logSet() writes to SQLite but does NOT emit Cubit state.
  // setState updates the checkbox immediately.
  // RestTimerDialog appears after the set is logged.
  //
  // _processing guard: prevents a double-tap from logging the
  // same set twice while the first logSet() await is in flight.
  Future<void> _onSetTapped(ResolvedExercise exercise, int setNumber) async {
    final key = _SetKey(exercise.model.exerciseId, setNumber);

    // Uncheck: no guard needed — this is instant, no async work.
    if (_completedSets.containsKey(key)) {
      setState(() => _completedSets.remove(key));
      return;
    }

    // Guard: block re-entry while logSet() is in progress.
    if (_processing) return;
    setState(() => _processing = true);

    // Check: log the set to SQLite and show rest timer.
    try {
      final log = await context.read<WorkoutController>().logSet(
        sessionId: widget.session.id,
        exerciseId: exercise.model.exerciseId,
        setNumber: setNumber,
        reps: exercise.model.reps,
        weight: exercise.model.weight,
      );
      if (!mounted) return;
      setState(() => _completedSets[key] = log);

      // Auto-expand the next exercise card after the last set
      // of the current exercise is completed.
      final exerciseIndex = widget.exercises.indexWhere(
        (e) => e.model.exerciseId == exercise.model.exerciseId,
      );
      final completedForExercise = _completedSets.keys
          .where((k) => k.exerciseId == exercise.model.exerciseId)
          .length;
      if (completedForExercise == exercise.model.sets &&
          exerciseIndex < widget.exercises.length - 1) {
        setState(() => _expanded[exerciseIndex + 1] = true);
      }

      // Show rest timer dialog.
      if (mounted) {
        _showRestTimer(exercise.model.restSeconds);
      }
    } catch (_) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Could not log set.');
      }
    } finally {
      // Always release the guard — even if logSet() threw.
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── Rest timer dialog ─────────────────────────────────────
  // Uses the shared RestTimerDialog from
  // lib/shared/widgets/misc/rest_timer_dialog.dart.
  // onSkip: Navigator.pop already handled inside RestTimerDialog —
  //   the callback here is a no-op because the dialog dismisses
  //   itself. We pass an empty callback to satisfy the required param.
  // onReset: no-op — reset is fully self-contained inside the dialog.
  void _showRestTimer(int seconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RestTimerDialog(
        seconds: seconds,
        onSkip: () {}, // dialog handles its own pop
        onReset: () {}, // dialog handles its own reset
      ),
    );
  }

  // ── Finish session ────────────────────────────────────────
  // Shows confirm dialog first — prevents accidental taps.
  void _confirmFinish() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _kCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Finish Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$_completedSetCount of $_totalSets sets completed.',
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
              _finishSession();
            },
            child: Text(
              AppStrings.finishButton,
              style: TextStyle(color: AppColors.steelColor),
            ),
          ),
        ],
      ),
    );
  }

  // Pauses timer, calls finishSession().
  // BlocConsumer listener navigates to WorkoutSummaryScreen
  // when WorkoutLoaded is emitted.
  void _finishSession() {
    setState(() => _isPaused = true);
    context.read<WorkoutController>().finishSession(
      widget.session,
      _logs,
      widget.userId,
      widget.userId, // uid same as userId until AuthCubit is wired
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutController, WorkoutState>(
      // Only react to finishSession() completing or failing.
      listenWhen: (previous, current) =>
          previous is WorkoutLoading &&
          (current is WorkoutLoaded || current is WorkoutError),
      listener: (context, state) {
        if (state is WorkoutError) {
          // Re-enable timer on error so session can continue.
          setState(() => _isPaused = false);
          Helpers.showErrorSnackBar(context, state.message);
        }
        if (state is WorkoutLoaded && state.activeSession != null) {
          // Navigate to WorkoutSummaryScreen, replacing this screen
          // so back button doesn't return to a finished session.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutSummaryScreen(
                session: state.activeSession!,
                logs: _logs,
                userId: widget.userId,
              ),
            ),
          );
        }
      },
      buildWhen: (_, current) =>
          current is WorkoutLoading ||
          current is WorkoutLoaded ||
          current is WorkoutError,
      builder: (context, state) {
        // isFinishing: overlay shown only during WorkoutLoading.
        // When WorkoutError fires, state is no longer WorkoutLoading
        // so overlay clears and the user can continue the session.
        final isFinishing = state is WorkoutLoading;

        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: _buildAppBar(isFinishing),
          body: isFinishing ? _buildFinishingOverlay() : _buildBody(),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isFinishing) {
    return AppBar(
      backgroundColor: AppColors.splashBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: isFinishing ? null : _confirmFinish,
      ),
      title: Text(
        widget.workout.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
    );
  }

  // ── Finishing overlay ──────────────────────────────────────
  Widget _buildFinishingOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.steelColor,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Saving session…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Scrollable body ────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimerRow(),
          const SizedBox(height: 14),
          _buildProgressBar(),
          const SizedBox(height: 20),
          ...List.generate(widget.exercises.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildExerciseCard(i),
            );
          }),
        ],
      ),
    );
  }

  // ── Timer row ─────────────────────────────────────────────
  Widget _buildTimerRow() {
    return Row(
      children: [
        // Timer label + value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.activeSession,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.steelColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pause/Resume button
        GestureDetector(
          onTap: _togglePause,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Finish button
        GestureDetector(
          onTap: _confirmFinish,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.steelColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              AppStrings.finishButton,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Progress bar ───────────────────────────────────────────
  Widget _buildProgressBar() {
    final pct = (_progressValue * 100).round();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.workoutProgress,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: AppColors.steelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.steelColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Exercise card ──────────────────────────────────────────
  Widget _buildExerciseCard(int index) {
    final ex = widget.exercises[index];
    final expanded = _expanded[index];

    // Count completed sets for this exercise.
    final completedForEx = _completedSets.keys
        .where((k) => k.exerciseId == ex.model.exerciseId)
        .length;
    final allDone = completedForEx == ex.model.sets;

    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allDone
              ? AppColors.success.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          // ── Card header ──────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded[index] = !expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  // Done indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: allDone
                          ? AppColors.success
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name + muscle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ex.muscleGroup.isNotEmpty)
                          Text(
                            ex.muscleGroup,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Expand/collapse chevron
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ── Set rows (only when expanded) ────────────────
          if (expanded) ...[
            Divider(
              color: Colors.white.withValues(alpha: 0.08),
              height: 1,
              thickness: 1,
            ),
            _buildSetTable(ex),
          ],
        ],
      ),
    );
  }

  // ── Set table ─────────────────────────────────────────────
  Widget _buildSetTable(ResolvedExercise ex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    AppStrings.setsLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    AppStrings.repsLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: 40,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Set rows
          ...List.generate(ex.model.sets, (setIdx) {
            final setNumber = setIdx + 1; // 1-based
            final key = _SetKey(ex.model.exerciseId, setNumber);
            final done = _completedSets.containsKey(key);

            // Active row = first uncompleted set in this exercise.
            final completedCount = _completedSets.keys
                .where((k) => k.exerciseId == ex.model.exerciseId)
                .length;
            final isActive = !done && setIdx == completedCount;

            return GestureDetector(
              onTap: () => _onSetTapped(ex, setNumber),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? _kActiveRow : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? AppColors.steelColor.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    // Set number
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$setNumber',
                        style: TextStyle(
                          color: isActive
                              ? AppColors.steelColor
                              : Colors.white.withValues(alpha: 0.65),
                          fontSize: 15,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Reps
                    Expanded(
                      child: Text(
                        '${ex.model.reps}',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: done ? 0.45 : 0.85,
                          ),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Checkbox
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: done
                            ? Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.steelColor
                                        : Colors.white.withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

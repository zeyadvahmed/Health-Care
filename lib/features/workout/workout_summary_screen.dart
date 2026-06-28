// ============================================================
// workout_summary_screen.dart
// lib/features/workout/workout_summary_screen.dart
//
// Shown immediately after the user taps Finish in
// ActiveSessionScreen and finishSession() completes.
//
// WHAT IT SHOWS:
//   - Celebration header: "Workout Complete" + +50 XP earned
//   - 4 stat badges: Duration, Volume, Exercises, Calories
//   - XP progress bar (current level progress)
//   - Save & Exit button → navigates to WorkoutsListScreen
//     (pushNamedAndRemoveUntil clears the entire session stack)
//
// DATA SOURCE:
//   All data is passed in as constructor parameters — this screen
//   makes NO async calls and does NOT use BlocBuilder.
//   The controller already computed all values in finishSession().
//
// NAVIGATION:
//   Incoming : Navigator.pushReplacement from ActiveSessionScreen
//              (back button must NOT return to a finished session)
//   Save & Exit → AppRoutes.workouts via pushNamedAndRemoveUntil,
//                 removing ActiveSessionScreen and this screen.
//
// XP NOTE:
//   LocalActivityService is not implemented yet.
//   XP values are shown as static placeholders (+50 XP, level 1).
//   When LocalActivityService is ready, pass ActivityModel in
//   and read real values from it.
//
// RULES FOLLOWED:
//   - StatelessWidget — all data is immutable after session ends
//   - withValues(alpha:) — withOpacity() is deprecated
//   - AppColors only — never raw Color()
//   - AppStrings for all UI text
//   - pushNamedAndRemoveUntil to prevent back-nav to session
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/session_log_model.dart';
import '../../routes/app_routes.dart';

// ── File-level color constants ─────────────────────────────────
// TODO: Move into AppColors once design palette is finalised.
const Color _kCardBg = Color(0xFF0D3358); // stat badge / card bg
const Color _kCelebBg = Color(0xFF0A2540); // celebration header bg

// ─────────────────────────────────────────────────────────────
// WorkoutSummaryScreen
// ─────────────────────────────────────────────────────────────
class WorkoutSummaryScreen extends StatelessWidget {
  // Completed session — has endTime, totalVolume, totalDuration,
  // caloriesBurned all filled in by finishSession().
  final WorkoutSessionModel session;

  // Logs passed from ActiveSessionScreen — used to count
  // completed exercises (distinct exerciseIds in logs).
  final List<SessionLogModel> logs;

  // userId passed through for pushNamedAndRemoveUntil navigation.
  final String userId;

  const WorkoutSummaryScreen({
    super.key,
    required this.session,
    required this.logs,
    this.userId = '',
  });

  // ── Computed display values ───────────────────────────────
  // Duration string from totalDuration (seconds).
  String get _durationText {
    final totalSecs = session.totalDuration;
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final s = totalSecs % 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    if (m > 0) return '${m}min';
    return '${s}s';
  }

  // Volume formatted — show in kg with 1 decimal.
  String get _volumeText {
    if (session.totalVolume >= 1000) {
      return '${(session.totalVolume / 1000).toStringAsFixed(1)}t';
    }
    return '${session.totalVolume.toStringAsFixed(0)} kg';
  }

  // Count of distinct exercises completed (not total sets).
  int get _exerciseCount => logs.map((l) => l.exerciseId).toSet().length;

  // Calories burned rounded to nearest 10 for display.
  String get _caloriesText => '${session.caloriesBurned} kcal';

  // XP awarded per session — flat 100 XP.
  // Replace with real ActivityModel value when service is built.
  static const int _xpEarned = 100;

  // Placeholder XP progress values until ActivityModel is wired.
  // currentXp / xpForNextLevel shown in progress bar.
  static const int _currentXp = 350; // placeholder
  static const int _xpForNextLevel = 500; // placeholder
  static const int _currentLevel = 1; // placeholder

  double get _xpProgress => (_currentXp / _xpForNextLevel).clamp(0.0, 1.0);

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCelebrationHeader(),
            const SizedBox(height: 20),
            _buildStatGrid(),
            const SizedBox(height: 20),
            _buildXpCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveBar(context),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.splashBackground,
      elevation: 0,
      // X button — same as Save & Exit (clears stack).
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 22),
        onPressed: () => _exit(context),
      ),
      title: const Text(
        AppStrings.workoutSummary,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Celebration header ─────────────────────────────────────
  Widget _buildCelebrationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: _kCelebBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.steelColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Celebration icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.xpGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: AppColors.xpGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            AppStrings.workoutComplete,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // XP earned pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.xpGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.xpGold.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '+$_xpEarned ${AppStrings.xpEarned}',
              style: TextStyle(
                color: AppColors.xpGold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat badges — 2×2 grid ─────────────────────────────────
  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatBadge(
                icon: Icons.timer_outlined,
                label: AppStrings.durationStat,
                value: _durationText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBadge(
                icon: Icons.fitness_center,
                label: AppStrings.volumeStat,
                value: _volumeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatBadge(
                icon: Icons.directions_run,
                label: AppStrings.exercisesStat,
                value: '$_exerciseCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBadge(
                icon: Icons.local_fire_department_outlined,
                label: AppStrings.caloriesStat,
                value: _caloriesText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── XP progress card ───────────────────────────────────────
  Widget _buildXpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level label + XP fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $_currentLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${AppStrings.nextLevel}$_currentXp / $_xpForNextLevel XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.xpGold),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom save bar ────────────────────────────────────────
  Widget _buildSaveBar(BuildContext context) {
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
          onPressed: () => _exit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.steelColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            AppStrings.saveAndExit,
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

  // ── Exit helper ────────────────────────────────────────────
  // Clears entire navigation stack back to WorkoutsListScreen.
  // pushNamedAndRemoveUntil ensures neither ActiveSessionScreen
  // nor this screen remain in the back stack.
  void _exit(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }
}

// ════════════════════════════════════════════════════════════
// _StatBadge
// One stat card: icon + label + large value.
// Used in the 2×2 grid.
// StatelessWidget — displays fixed data only.
// ════════════════════════════════════════════════════════════
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.steelColor, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// create_workout_screen.dart
// lib/features/workout/create_workout_screen.dart
//
// Dual-mode screen:
//   existingWorkout == null  → CREATE mode (new workout)
//   existingWorkout != null  → EDIT mode   (update existing)
//
// Form fields:
//   - Workout name       (required)
//   - Description        (optional)
//   - Difficulty         (dropdown: beginner / intermediate / expert)
//   - Duration           (minutes, number input)
//   - Exercise list      (add / edit / remove inline)
//
// State management: BlocConsumer<WorkoutController, WorkoutState>
//   - listener: pops on WorkoutLoaded (save success)
//               shows error snackbar on WorkoutError
//   - builder:  shows loading overlay during WorkoutLoading
//
// Navigation:
//   + Add Exercise → AddExerciseScreen (Navigator.push — PASS DATA)
//   Edit exercise  → AddExerciseScreen (Navigator.push — PASS DATA)
//   Both await AddExerciseResult returned via Navigator.pop.
//
// Rules followed:
//   - withValues(alpha:) — withOpacity() is deprecated
//   - AppColors only — never raw Color()
//   - AppStrings only — never raw string literals in UI
//   - resolveExerciseNames() only in initState — never in build()
//   - PASS DATA screens → Navigator.push + MaterialPageRoute
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/workout_model.dart';
import 'workout_controller.dart';
import 'workout_state.dart';
import 'add_exercise_screen.dart';

// ── File-level color constants ────────────────────────────────
// TODO: Move into AppColors once the design palette is finalised.
const Color _kCardBg = Color(0xFF0D3358); // card / section background
const Color _kDarkFill = Color(0xFF082035); // input field fill

// ─────────────────────────────────────────────────────────────
// CreateWorkoutScreen
// ─────────────────────────────────────────────────────────────
class CreateWorkoutScreen extends StatefulWidget {
  // userId passed from WorkoutsListScreen.
  final String userId;

  // null → create mode; non-null → edit mode.
  final WorkoutModel? existingWorkout;

  const CreateWorkoutScreen({
    super.key,
    required this.userId,
    this.existingWorkout,
  });

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  // ── Form key ──────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;

  // ── Form state ────────────────────────────────────────────
  String _difficulty = 'beginner';

  // ── Exercise list ─────────────────────────────────────────
  // Each entry is an AddExerciseResult returned by AddExerciseScreen.
  // Not saved to SQLite until the user taps Save Workout.
  final List<AddExerciseResult> _exercises = [];

  // ── UUID ──────────────────────────────────────────────────
  final _uuid = const Uuid();

  // ── Computed helpers ──────────────────────────────────────
  bool get _isEditMode => widget.existingWorkout != null;

  String get _estimatedDurationText {
    final mins = int.tryParse(_durationCtrl.text) ?? 0;
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${mins}min';
  }

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final w = widget.existingWorkout;
    _nameCtrl = TextEditingController(text: w?.name ?? '');
    _descCtrl = TextEditingController(text: w?.description ?? '');
    _durationCtrl = TextEditingController(text: '${w?.durationMinutes ?? 45}');
    _difficulty = w?.difficulty ?? 'beginner';

    // Edit mode: load existing exercises from SQLite.
    // resolveExerciseNames() called here — ONLY in initState.
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingExercises();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  // ── Load existing exercises (edit mode only) ──────────────
  Future<void> _loadExistingExercises() async {
    final ctrl = context.read<WorkoutController>();
    final raw = await ctrl.getExercisesForWorkout(widget.existingWorkout!.id);

    // resolveExerciseNames() maps exerciseId → ExerciseModel.
    // CRITICAL: only called here in initState callback.
    final nameMap = await ctrl.resolveExerciseNames(raw);

    if (!mounted) return;
    setState(() {
      for (final we in raw) {
        final ex = nameMap[we.exerciseId];
        _exercises.add(
          AddExerciseResult(
            model: we,
            displayName: ex?.name ?? we.exerciseId,
            muscleGroup: ex?.primaryMuscles.join(', ') ?? '',
          ),
        );
      }
    });
  }

  // ── Save workout ──────────────────────────────────────────
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final workoutId = widget.existingWorkout?.id ?? _uuid.v4();
    final durationMins = int.tryParse(_durationCtrl.text.trim()) ?? 45;

    final workout = WorkoutModel(
      id: workoutId,
      userId: widget.userId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      difficulty: _difficulty,
      durationMinutes: durationMins,
      isPredefined: false,
      // imageUrl: null for user-created workouts.
      // Predefined workouts get their imageUrl from Firestore seeding,
      // never from this screen.
      imageUrl: null,
      createdAt: widget.existingWorkout?.createdAt ?? now,
      updatedAt: now,
      isSynced: false,
    );

    // Re-index orderIndex before saving to preserve display order.
    final exercises = _exercises
        .asMap()
        .entries
        .map(
          (e) =>
              e.value.model.copyWith(workoutId: workoutId, orderIndex: e.key),
        )
        .toList();

    context.read<WorkoutController>().saveWorkout(
      workout,
      exercises,
      widget.userId,
    );
  }

  // ── Add exercise ──────────────────────────────────────────
  // Pushes AddExerciseScreen and appends the returned result.
  Future<void> _addExercise() async {
    final result = await Navigator.push<AddExerciseResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddExerciseScreen(workoutId: widget.existingWorkout?.id ?? ''),
      ),
    );
    if (result != null && mounted) {
      setState(() => _exercises.add(result));
    }
  }

  // ── Edit exercise ─────────────────────────────────────────
  // Pushes AddExerciseScreen pre-filled and replaces the entry.
  Future<void> _editExercise(int index) async {
    final result = await Navigator.push<AddExerciseResult>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExerciseScreen(
          workoutId: widget.existingWorkout?.id ?? '',
          existingResult: _exercises[index],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _exercises[index] = result);
    }
  }

  // ── Remove exercise ───────────────────────────────────────
  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutController, WorkoutState>(
      // Only react to state transitions that this screen triggered.
      // listenWhen ensures we only react to state transitions this screen
      // triggered — not to WorkoutLoaded emitted by loadWorkouts() elsewhere.
      // We allow two transitions through:
      //   Loading → Loaded : our save completed successfully → pop
      //   Loading → Error  : our save failed → show error snackbar
      listenWhen: (previous, current) =>
          previous is WorkoutLoading &&
          (current is WorkoutLoaded || current is WorkoutError),
      listener: (context, state) {
        if (state is WorkoutLoaded) {
          Navigator.pop(context);
        }
        if (state is WorkoutError) {
          Helpers.showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is WorkoutLoading;

        return Scaffold(
          backgroundColor: AppColors.splashBackground,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        children: [
                          _sectionTitle(
                            Icons.info_outline,
                            AppStrings.workoutInfo,
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('Workout Name'),
                          const SizedBox(height: 6),
                          _nameField(),
                          const SizedBox(height: 16),
                          _fieldLabel('Description (Optional)'),
                          const SizedBox(height: 6),
                          _descriptionField(),
                          const SizedBox(height: 16),
                          _fieldLabel(AppStrings.difficultyLabel),
                          const SizedBox(height: 6),
                          _difficultyDropdown(),
                          const SizedBox(height: 16),
                          _fieldLabel(AppStrings.durationLabel),
                          const SizedBox(height: 6),
                          _durationField(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _exercisesSection(),
                    ],
                  ),
                ),
              ),
              if (isSaving)
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
          bottomSheet: _buildBottomBar(isSaving),
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
      title: Text(
        _isEditMode ? 'Edit Workout' : AppStrings.createWorkout,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── UI helpers ────────────────────────────────────────────
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.steelColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Form fields ───────────────────────────────────────────
  Widget _nameField() {
    return TextFormField(
      controller: _nameCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Workout name is required';
        }
        if (v.trim().length < 3) {
          return 'Name must be at least 3 characters';
        }
        return null;
      },
      decoration: _inputDecoration(AppStrings.workoutNameHint),
    );
  }

  Widget _descriptionField() {
    return TextFormField(
      controller: _descCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      maxLines: 3,
      decoration: _inputDecoration(AppStrings.descriptionHint),
    );
  }

  Widget _difficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _difficulty,
      dropdownColor: _kCardBg,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
      decoration: _inputDecoration(''),
      items: const [
        DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
        DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
        DropdownMenuItem(value: 'expert', child: Text('Expert')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _difficulty = v);
      },
    );
  }

  Widget _durationField() {
    return TextFormField(
      controller: _durationCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Enter duration in minutes';
        }
        final n = int.tryParse(v);
        if (n == null || n < 1) {
          return 'Enter a valid duration (min 1)';
        }
        return null;
      },
      decoration: _inputDecoration('e.g. 45').copyWith(
        suffixText: 'min',
        suffixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 13,
      ),
      filled: true,
      fillColor: _kDarkFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.steelColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  // ── Exercises section ─────────────────────────────────────
  Widget _exercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_run,
                  color: AppColors.steelColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.exercisesLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _addExercise,
              child: Text(
                AppStrings.addExercise,
                style: TextStyle(
                  color: AppColors.steelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_exercises.isEmpty) _emptyExercisesHint(),
        ...List.generate(_exercises.length, (i) {
          final entry = _exercises[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExerciseListTile(
              entry: entry,
              onEdit: () => _editExercise(i),
              onDelete: () => _removeExercise(i),
            ),
          );
        }),
      ],
    );
  }

  Widget _emptyExercisesHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.white24, size: 32),
          const SizedBox(height: 8),
          Text(
            'No exercises added yet.\nTap + Add Exercise to begin.',
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

  // ── Bottom save bar ───────────────────────────────────────
  Widget _buildBottomBar(bool isSaving) {
    return Container(
      color: AppColors.splashBackground,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.estimatedDuration,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_estimatedDurationText · ${_exercises.length} '
                  '${_exercises.length == 1 ? 'Exercise' : 'Exercises'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 145,
            height: 46,
            child: ElevatedButton(
              onPressed: isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.steelColor,
                disabledBackgroundColor: AppColors.steelColor.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      AppStrings.saveWorkout,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _ExerciseListTile
// Compact tile showing one exercise inside the create/edit form.
// Uses AddExerciseResult — the type returned by AddExerciseScreen.
// ════════════════════════════════════════════════════════════
class _ExerciseListTile extends StatelessWidget {
  final AddExerciseResult entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseListTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final we = entry.model;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.steelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.steelColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Name + chips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (entry.muscleGroup.isNotEmpty) ...[
                      _chip(
                        entry.muscleGroup.split(',').first.trim(),
                        Colors.white54,
                        Colors.white.withValues(alpha: 0.08),
                      ),
                      const SizedBox(width: 5),
                    ],
                    _chip(
                      '${we.sets} × ${we.reps}',
                      AppColors.steelColor,
                      AppColors.steelColor.withValues(alpha: 0.15),
                    ),
                    const SizedBox(width: 5),
                    _chip(
                      we.weight != null
                          ? '${we.weight!.toStringAsFixed(1)} kg'
                          : 'BW',
                      Colors.white60,
                      Colors.white.withValues(alpha: 0.06),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.steelColor,
                size: 18,
              ),
            ),
          ),

          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Icon(Icons.close, color: AppColors.error, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

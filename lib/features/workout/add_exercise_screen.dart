// ============================================================
// add_exercise_screen.dart
// lib/features/workout/add_exercise_screen.dart
//
// Full-screen form for adding or editing one exercise inside
// a workout. This screen does NOT save to SQLite directly —
// it pops with an AddExerciseResult that create_workout_screen
// appends to its local exercise list before the full workout save.
//
// MODES:
//   existingResult == null  → ADD mode  (blank form)
//   existingResult != null  → EDIT mode (pre-filled form)
//
// RETURN VALUE:
//   Navigator.pop(context, AddExerciseResult(...))
//   Caller reads result from Navigator.push(...).then((result) {...})
//
// NAVIGATION:
//   Called from create_workout_screen via Navigator.push:
//
//     final result = await Navigator.push<AddExerciseResult>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddExerciseScreen(
//           workoutId: workoutId,
//           existingResult: existingEntry, // null = add, non-null = edit
//         ),
//       ),
//     );
//     if (result != null) { /* append or update local list */ }
//
// FUTURE INTEGRATION — ExerciseSearchScreen:
//   When ExerciseSearchScreen is built, the flow becomes:
//     create_workout_screen → ExerciseSearchScreen
//     ExerciseSearchScreen → AddExerciseScreen(preselectedExercise: ex)
//   AddExerciseScreen pre-fills name + muscleGroup from ExerciseModel.
//   The preselectedExercise parameter and its handling are already
//   stubbed below — uncomment when ExerciseSearchScreen is ready.
//
// RULES FOLLOWED:
//   - No Bloc — this screen manages only local form state
//   - AppColors only — never raw Color()
//   - AppStrings only — never raw strings in UI
//   - withValues(alpha:) — withOpacity() is deprecated
//   - Returns via Navigator.pop — never saves to SQLite here
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/workout_exercise_model.dart';
// import '../../data/models/exercise_model.dart'; // ← uncomment when ExerciseSearchScreen is built

// ── File-level color constants ────────────────────────────────
// These dark-navy tones are shared with create_workout_screen.
// TODO: move into AppColors once palette is finalised.
const Color _kCardBg   = Color(0xFF0D3358); // section / card background
const Color _kDarkFill = Color(0xFF082035); // input field fill

// ─────────────────────────────────────────────────────────────
// AddExerciseResult
//
// The object this screen returns via Navigator.pop().
// Carries the WorkoutExerciseModel plus the display strings
// so the caller can render tiles without extra SQLite lookups.
//
// IMPORTANT: displayName and muscleGroup are UI-only strings.
//   - When coming from manual entry: typed by the user.
//   - When coming from ExerciseSearchScreen (future): filled
//     from ExerciseModel.name and primaryMuscles.join(', ').
// ─────────────────────────────────────────────────────────────
class AddExerciseResult {
  final WorkoutExerciseModel model;

  // Human-readable exercise name — used in exercise tiles.
  final String displayName;

  // Muscle group label — used as subtitle in tiles.
  final String muscleGroup;

  const AddExerciseResult({
    required this.model,
    required this.displayName,
    required this.muscleGroup,
  });
}

// ─────────────────────────────────────────────────────────────
// Muscle group category options shown in the dropdown.
// These match the 'category' values in the exercise JSON DB.
// ─────────────────────────────────────────────────────────────
const List<String> _kMuscleCategories = [
  'Chest',
  'Back',
  'Shoulders',
  'Arms',
  'Legs',
  'Core',
  'Cardio',
  'Full Body',
  'Other',
];

// ─────────────────────────────────────────────────────────────
// AddExerciseScreen
// ─────────────────────────────────────────────────────────────
class AddExerciseScreen extends StatefulWidget {
  // workoutId will be '' when coming from create_workout_screen
  // before the workout is saved. create_workout_screen fills it
  // in with copyWith(workoutId: workoutId) before saving.
  final String workoutId;

  // null → add mode; non-null → edit mode (pre-fills form).
  final AddExerciseResult? existingResult;

  // FUTURE: pre-selected exercise from ExerciseSearchScreen.
  // Uncomment the parameter AND its usage in initState once
  // ExerciseSearchScreen is built:
  //
  // final ExerciseModel? preselectedExercise;

  const AddExerciseScreen({
    super.key,
    this.workoutId = '',
    this.existingResult,
    // this.preselectedExercise,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  // ── Form key ──────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;

  // ── Dropdown / stepper / chip state ───────────────────────
  String? _selectedCategory;   // null = "Select Category" (unselected)
  int _sets        = 3;
  int _reps        = 10;
  int _restSeconds = 60;
  bool _isKg       = true;     // KG/LBS toggle

  // ── UUID ──────────────────────────────────────────────────
  final _uuid = const Uuid();

  // ── Computed helpers ──────────────────────────────────────
  bool get _isEditMode => widget.existingResult != null;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final ex = widget.existingResult;

    _nameCtrl   = TextEditingController(text: ex?.displayName ?? '');

    // Pre-fill weight — convert from kg to lbs if toggled later.
    _weightCtrl = TextEditingController(
      text: ex?.model.weight != null
          ? ex!.model.weight!.toStringAsFixed(1)
          : '',
    );

    if (ex != null) {
      _sets        = ex.model.sets;
      _reps        = ex.model.reps;
      _restSeconds = ex.model.restSeconds;

      // Match stored muscle group to a category in the dropdown list.
      // CRITICAL: _selectedCategory MUST be null or one of the values
      // in _kMuscleCategories. If it holds any other string,
      // DropdownButtonFormField throws:
      //   "There should be exactly one item with DropdownButton's value"
      // So orElse always falls back to 'Other' (last item) — never
      // returns the stored string if it isn't in the list.
      final stored = ex.muscleGroup;
      _selectedCategory = _kMuscleCategories.firstWhere(
        (c) => c.toLowerCase() == stored.toLowerCase(),
        orElse: () => 'Other',
      );
    }

    // FUTURE — pre-fill from ExerciseSearchScreen result:
    // if (widget.preselectedExercise != null) {
    //   final e = widget.preselectedExercise!;
    //   _nameCtrl.text = e.name;
    //   final cat = e.category;
    //   _selectedCategory = _kMuscleCategories.firstWhere(
    //     (c) => c.toLowerCase() == cat.toLowerCase(),
    //     orElse: () => _kMuscleCategories.last,
    //   );
    // }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Parse weight — convert lbs → kg if LBS mode is active.
    double? weightKg;
    final rawWeight = double.tryParse(_weightCtrl.text.trim());
    if (rawWeight != null) {
      weightKg = _isKg ? rawWeight : rawWeight * 0.453592;
    }

    final now = DateTime.now();

    final model = WorkoutExerciseModel(
      id:          _isEditMode
                     ? widget.existingResult!.model.id
                     : _uuid.v4(),
      workoutId:   widget.workoutId,
      // exerciseId:
      //   EDIT   → keep existing (may be a real DB id or a custom_ uuid)
      //   ADD    → 'custom_<uuid>' — replaced when ExerciseSearchScreen
      //            returns a real ExerciseModel with a DB exerciseId
      exerciseId:  _isEditMode
                     ? widget.existingResult!.model.exerciseId
                     : 'custom_${_uuid.v4()}',
      sets:        _sets,
      reps:        _reps,
      weight:      weightKg,
      restSeconds: _restSeconds,
      orderIndex:  _isEditMode
                     ? widget.existingResult!.model.orderIndex
                     : 0, // create_workout_screen re-indexes before saving
      updatedAt:   now,
      isSynced:    false,
    );

    Navigator.pop(
      context,
      AddExerciseResult(
        model:        model,
        displayName:  _nameCtrl.text.trim(),
        muscleGroup:  _selectedCategory ?? '',
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Exercise name ────────────────────────────
              _fieldLabel('Exercise Name *'),
              const SizedBox(height: 6),
              _nameField(),
              const SizedBox(height: 16),

              // ── Muscle group dropdown ────────────────────
              _fieldLabel(AppStrings.muscleGroupLabel),
              const SizedBox(height: 6),
              _muscleGroupDropdown(),
              const SizedBox(height: 20),

              // ── Sets + Reps steppers ─────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StepperWidget(
                      label: AppStrings.setsLabel,
                      value: _sets,
                      min: 1,
                      max: 20,
                      onChanged: (v) => setState(() => _sets = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StepperWidget(
                      label: AppStrings.repsLabel,
                      value: _reps,
                      min: 1,
                      max: 50,
                      onChanged: (v) => setState(() => _reps = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Weight + KG/LBS toggle ───────────────────
              _fieldLabel(AppStrings.weightLabel),
              const SizedBox(height: 6),
              _weightField(),
              const SizedBox(height: 20),

              // ── Rest time chips ──────────────────────────
              _fieldLabel('Rest Time'),
              const SizedBox(height: 8),
              _restChips(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar (NOT bottomSheet) so it shifts up
      // automatically when the keyboard opens — prevents the save
      // button from overlapping the notes field.
      bottomNavigationBar: _buildBottomBar(),
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
        _isEditMode ? 'Edit Exercise' : AppStrings.addExerciseTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Form helpers ──────────────────────────────────────────

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

  // Shared InputDecoration for all TextFormFields.
  InputDecoration _inputDecoration(String hint, {String? suffixText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 13,
      ),
      filled: true,
      fillColor: _kDarkFill,
      suffixText: suffixText,
      suffixStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 13,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.steelColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
    );
  }

  // ── Name field ───────────────────────────────────────────
  Widget _nameField() {
    return TextFormField(
      controller: _nameCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Exercise name is required';
        }
        if (v.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
      decoration: _inputDecoration(AppStrings.exerciseNameHint),
    );
  }

  // ── Muscle group dropdown ────────────────────────────────
  Widget _muscleGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: _kCardBg,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      icon: const Icon(
          Icons.keyboard_arrow_down, color: Colors.white54),
      hint: Text(
        AppStrings.selectCategory,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 13,
        ),
      ),
      decoration: _inputDecoration(''),
      items: _kMuscleCategories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
    );
  }

  // ── Weight field with KG/LBS toggle ─────────────────────
  Widget _weightField() {
    return Row(
      children: [
        // Weight input
        Expanded(
          child: TextFormField(
            controller: _weightCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              // Allow digits and a single dot only.
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            decoration: _inputDecoration(
              '0.0',
              suffixText: _isKg ? 'kg' : 'lbs',
            ),
          ),
        ),
        const SizedBox(width: 10),

        // KG / LBS toggle
        Container(
          decoration: BoxDecoration(
            color: _kDarkFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              _unitToggleBtn('KG', _isKg, () {
                if (!_isKg) {
                  _convertWeight(toKg: true);
                  setState(() => _isKg = true);
                }
              }),
              _unitToggleBtn('LBS', !_isKg, () {
                if (_isKg) {
                  _convertWeight(toKg: false);
                  setState(() => _isKg = false);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Unit toggle button pill (KG / LBS).
  Widget _unitToggleBtn(
      String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: active
              ? AppColors.steelColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: active
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Convert the displayed weight value when toggling KG ↔ LBS.
  void _convertWeight({required bool toKg}) {
    final raw = double.tryParse(_weightCtrl.text.trim());
    if (raw == null) return;
    final converted = toKg
        ? raw * 0.453592  // lbs → kg
        : raw * 2.20462;  // kg → lbs
    _weightCtrl.text = converted.toStringAsFixed(1);
  }

  // ── Rest time chips ──────────────────────────────────────
  Widget _restChips() {
    return Wrap(
      spacing: 10,
      children: [30, 60, 90, 120].map((sec) {
        final selected = _restSeconds == sec;
        return GestureDetector(
          onTap: () => setState(() => _restSeconds = sec),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.steelColor
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.steelColor
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              '${sec}s',
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white54,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom save bar ──────────────────────────────────────
  Widget _buildBottomBar() {
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
        height: 50,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.steelColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Text(
            AppStrings.saveExercise,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// _StepperWidget
// + / − stepper for Sets and Reps fields.
// Private to this file — only used in AddExerciseScreen.
// ════════════════════════════════════════════════════════════
class _StepperWidget extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperWidget({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _kDarkFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_run,
                  color: AppColors.steelColor, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // − value + row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _btn(Icons.remove, value > min,
                  () => onChanged(value - 1)),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _btn(Icons.add, value < max,
                  () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(
      IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.steelColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? AppColors.steelColor
              : Colors.white24,
        ),
      ),
    );
  }
}
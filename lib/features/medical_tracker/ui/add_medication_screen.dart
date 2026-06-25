import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/medical_record_model.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/custom_textfield.dart';
import '../cubit/medical_cubit.dart';
import '../cubit/medical_state.dart';

class AddMedicationScreen extends StatefulWidget {
  final String userId;
  final String uid;

  // If provided → edit mode. If null → add mode.
  final MedicalRecordModel? existingRecord;

  const AddMedicationScreen({
    super.key,
    required this.userId,
    required this.uid,
    this.existingRecord,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;

  // ── Local state ───────────────────────────────────────────
  String _selectedType = 'Medicine';
  String _selectedFrequency = 'Once daily';
  List<TimeOfDay> _scheduleTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  // Type dropdown options
  final List<String> _types = [
    'Medicine',
    'Supplement',
    'Vitamin',
    'Injection',
    'Other',
  ];

  // Frequency chip options — matches Figma
  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Every X hours',
  ];

  // ── Edit mode helpers ─────────────────────────────────────
  bool get _isEditMode => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;

    // Pre-fill controllers in edit mode, empty in add mode
    _nameController = TextEditingController(text: r?.name ?? '');
    _dosageController = TextEditingController(text: r?.dosage ?? '');
    _notesController = TextEditingController(text: r?.notes ?? '');

    if (r != null) {
      _selectedType = r.type.isNotEmpty ? r.type : 'Medicine';
      _selectedFrequency = r.frequency.isNotEmpty ? r.frequency : 'Once daily';
      _startDate = DateTime.parse(r.startDate);

      if (r.endDate != null) {
        _endDate = DateTime.parse(r.endDate!);
      }
      // Parse reminderTime back to TimeOfDay for display
      _scheduleTimes = _parseReminderTimes(r.scheduleTimes.join(', '));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<TimeOfDay> _parseReminderTimes(String reminderTime) {
    try {
      return reminderTime.split(',').map((t) {
        final trimmed = t.trim();
        final parts = trimmed.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }).toList();
    } catch (_) {
      return [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  String _formatReminderTimes() {
    return _scheduleTimes
        .map((t) {
          final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
          final minute = t.minute.toString().padLeft(2, '0');
          final period = t.period == DayPeriod.am ? 'AM' : 'PM';
          return '$hour:$minute $period';
        })
        .join(', ');
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduleTimes[index],
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.steelColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _scheduleTimes[index] = picked);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? DateTime(2020) : _startDate;
    final last = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.steelColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is never before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();

    if (_isEditMode) {
      // ── Edit mode — update existing record ──────────
      final updated = widget.existingRecord!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        scheduleTimes: _scheduleTimes.map((t) {
          final hour = t.hour.toString().padLeft(2, '0');
          final minute = t.minute.toString().padLeft(2, '0');
          return '$hour:$minute';
        }).toList(),
        startDate: _startDate.toIso8601String(),
        endDate: _endDate.toIso8601String(),
        notes: _notesController.text.trim(),
        updatedAt: now,
        isSynced: false,
      );
      await context.read<MedicalCubit>().updateMedicalRecord(
        updated,
        widget.uid,
      );
    } else {
      // ── Add mode — create new record ─────────────────
      final record = MedicalRecordModel(
        id: const Uuid().v4(),
        userId: widget.userId,
        name: _nameController.text.trim(),
        type: _selectedType,
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        scheduleTimes: _scheduleTimes.map((t) {
          final hour = t.hour.toString().padLeft(2, '0');
          final minute = t.minute.toString().padLeft(2, '0');
          return '$hour:$minute';
        }).toList(),
        startDate: _startDate.toIso8601String(),
        endDate: _endDate.toIso8601String(),
        notes: _notesController.text.trim(),
        isTaken: false,
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      );
      await context.read<MedicalCubit>().addMedicalRecord(record, widget.uid);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Medication' : AppStrings.addMedication),
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocListener<MedicalCubit, MedicalState>(
        listener: (context, state) {
          // Pop on successful loaded state after submit
          // (handled by Navigator.pop in _submit directly)
        },
        child: GestureDetector(
          // Dismiss keyboard on tap outside
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Medication Name ──────────────────
                  CustomTextfield(
                    label: AppStrings.medicationName,
                    hint: AppStrings.medicationNameHint,
                    controller: _nameController,
                    validator: Validators.validateMedicationName,
                  ),
                  const SizedBox(height: 16),

                  // ── Type dropdown ────────────────────
                  _SectionLabel(label: AppStrings.typeLabel),
                  const SizedBox(height: 8),
                  _TypeDropdown(
                    value: _selectedType,
                    items: _types,
                    onChanged: (val) =>
                        setState(() => _selectedType = val ?? _selectedType),
                  ),
                  const SizedBox(height: 16),

                  // ── Dosage ───────────────────────────
                  CustomTextfield(
                    label: AppStrings.dosageLabel,
                    hint: AppStrings.dosageHint,
                    controller: _dosageController,
                    validator: Validators.validateDosage,
                  ),
                  const SizedBox(height: 16),

                  // ── Frequency chips ──────────────────
                  _SectionLabel(label: AppStrings.frequencyLabel),
                  const SizedBox(height: 10),
                  _FrequencyChips(
                    options: _frequencies,
                    selected: _selectedFrequency,
                    onSelect: (val) => setState(() => _selectedFrequency = val),
                  ),
                  const SizedBox(height: 20),

                  // ── Schedule Time ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(label: AppStrings.scheduleTime),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _scheduleTimes.add(
                              const TimeOfDay(hour: 8, minute: 0),
                            );
                          });
                        },
                        child: const Text(
                          AppStrings.addTime,
                          style: TextStyle(
                            color: AppColors.steelColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Time slots list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _scheduleTimes.length,
                    itemBuilder: (context, index) {
                      return _TimeSlotTile(
                        time: _scheduleTimes[index],
                        onTap: () => _pickTime(index),
                        onDelete: _scheduleTimes.length > 1
                            ? () =>
                                  setState(() => _scheduleTimes.removeAt(index))
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Start / End Date row ─────────────
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: AppStrings.startDate,
                          value: _formatDate(_startDate),
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DatePickerField(
                          label: AppStrings.endDate,
                          value: _formatDate(_endDate),
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Notes (optional) ─────────────────
                  CustomTextfield(
                    label: '${AppStrings.notesLabel} (Optional)',
                    hint: 'Any additional notes...',
                    controller: _notesController,
                    validator: (_) => null, // optional field
                  ),
                  const SizedBox(height: 32),

                  // ── Save button ──────────────────────
                  BlocBuilder<MedicalCubit, MedicalState>(
                    builder: (context, state) {
                      return CustomButton(
                        label: AppStrings.saveButton,
                        onPressed: _submit,
                        isLoading: state is MedicalLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4C4C4C),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _TypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB1B1B1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF888888),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FrequencyChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FrequencyChips({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.steelColor.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.steelColor
                    : const Color(0xFFCCCCCC),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.steelColor
                    : const Color(0xFF444444),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TimeSlotTile({required this.time, required this.onTap, this.onDelete});

  String _formatted() {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.steelColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.steelColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatted(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // Only show delete if more than one slot
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF888888),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C4C4C),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFB1B1B1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF888888),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/hydration_entry_model.dart';
import '../../../shared/widgets/buttons/custom_button.dart';
import '../../../shared/widgets/inputs/custom_textfield.dart';
import '../cubit/hydration_cubit.dart';
import '../cubit/hydration_state.dart';

class AddWaterScreen extends StatefulWidget {
  final String userId;
  final String uid;

  // If provided → edit mode. If null → add mode.
  final HydrationEntryModel? existingEntry;

  const AddWaterScreen({
    super.key,
    required this.userId,
    required this.uid,
    this.existingEntry,
  });

  @override
  State<AddWaterScreen> createState() => _AddWaterScreenState();
}

class _AddWaterScreenState extends State<AddWaterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String _selectedType = 'Water';
  late TimeOfDay _selectedTime;

  // Water type options for the dropdown
  final List<String> _types = [
    'Water',
    'Tea',
    'Coffee',
    'Juice',
    'Electrolytes',
  ];

  bool get _isEditMode => widget.existingEntry != null;

  String get _title =>
      _isEditMode ? 'Edit Water Intake' : 'Add Water Intake';

  String get _buttonLabel => _isEditMode ? 'Save Changes' : 'Add Entry';

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;

    // Pre-fill controllers in edit mode, empty in add mode
    _amountController =
        TextEditingController(text: e != null ? '${e.amountMl}' : '');
    _selectedType = e?.type ?? 'Water';
    _selectedTime = e != null
        ? TimeOfDay(hour: e.timestamp.hour, minute: e.timestamp.minute)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.steelColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formattedTime() {
    final hour = _selectedTime.hourOfPeriod == 0
        ? 12
        : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period =
        _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime _buildTimestamp() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final amount = int.parse(_amountController.text.trim());
    final timestamp = _buildTimestamp();

    if (_isEditMode) {
      final updated = widget.existingEntry!.copyWith(
        amountMl: amount,
        type: _selectedType,
        timestamp: timestamp,
        updatedAt: now,
        isSynced: false,
      );
      await context
          .read<HydrationCubit>()
          .updateHydrationEntry(updated, widget.uid);
    } else {
      final entry = HydrationEntryModel(
        id: const Uuid().v4(),
        userId: widget.userId,
        amountMl: amount,
        type: _selectedType,
        dailyGoalMl: 2000, // default daily goal
        timestamp: timestamp,
        updatedAt: now,
        isSynced: false,
      );
      await context
          .read<HydrationCubit>()
          .addHydrationEntry(entry, widget.uid);
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    if (parsed > 5000) return 'Enter a realistic amount (max 5000 ml)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HydrationCubit, HydrationState>(
      listener: (context, state) {
        // Pop on success after cubit reloads entries
        if (state is HydrationLoaded) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
        // Show error snackbar if something went wrong
        if (state is HydrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          title: Text(_title),
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
        body: GestureDetector(
          // Dismiss keyboard on tap outside
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SubtitleText(
                    'Stay hydrated throughout the day',
                  ),
                  const SizedBox(height: 24),

                  CustomTextfield(
                    label: 'Amount (ml)',
                    hint: 'e.g. 250',
                    controller: _amountController,
                    validator: _validateAmount,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  const _FieldLabel('Water Type'),
                  const SizedBox(height: 8),
                  _TypeDropdown(
                    value: _selectedType,
                    items: _types,
                    onChanged: (val) =>
                        setState(() => _selectedType = val ?? _selectedType),
                  ),
                  const SizedBox(height: 16),

                  const _FieldLabel('Time'),
                  const SizedBox(height: 8),
                  _TimePickerField(
                    formattedTime: _formattedTime(),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 16),

                  const _FieldLabel('Quick Select'),
                  const SizedBox(height: 10),
                  _QuickAmountChips(
                    onSelect: (amount) {
                      setState(() {
                        _amountController.text = '$amount';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 32),

                  BlocBuilder<HydrationCubit, HydrationState>(
                    builder: (context, state) {
                      return CustomButton(
                        label: _buttonLabel,
                        onPressed: _submit,
                        isLoading: state is HydrationLoading,
                        color: AppColors.hydrationRing,
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

class _SubtitleText extends StatelessWidget {
  final String text;
  const _SubtitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF888888),
          ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

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

class _TimePickerField extends StatelessWidget {
  final String formattedTime;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFB1B1B1)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.steelColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountChips extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const _QuickAmountChips({required this.onSelect});

  static const List<int> _presets = [150, 250, 350, 500];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: _presets.map((amount) {
        return GestureDetector(
          onTap: () => onSelect(amount),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.hydrationRing.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.hydrationRing.withOpacity(0.40),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 13,
                  color: AppColors.hydrationRing,
                ),
                const SizedBox(width: 5),
                Text(
                  '$amount ml',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hydrationRing,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

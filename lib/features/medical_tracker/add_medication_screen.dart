// ============================================================
// add_medication_screen.dart
// Form for adding a new medication record.
//
// What to build:
//   - CustomAppBar title: 'Add Medication' with back button
//   - Medication name CustomTextField (validator: Validators.validateMedicationName)
//   - Type dropdown: pill / injection / supplement / other
//   - Dosage CustomTextField (validator: Validators.validateDosage)
//   - Frequency chips: Once daily / Twice daily / Every X hours (single select)
//   - Dynamic schedule times list with Add Time button
//     each time opens a TimePickerDialog, adds to list
//   - Start date picker → DatePicker dialog
//   - End date picker → DatePicker dialog (optional)
//   - Save CustomButton at bottom
//     → medicalController.saveMedication(record)
//     → Navigator.pop after save
//
// Rules:
//   - StatefulWidget — chip selection, dynamic times list, date pickers
//   - Validate form before saving
//   - Background color: AppColors.background
// ============================================================
// ============================================================
// medical_tracker_screen.dart
// Medication tracking screen.
//
// What to build:
//   - CustomAppBar title: 'Medical Tracker'
//   - Blue progress card: 'X of Y medications taken today'
//   - List of medication cards, each showing:
//       colored icon, medication name, dosage and schedule time,
//       checkbox to mark as taken for today
//   - If list is empty → EmptyStateWidget
//   - FAB '+' → pushNamed(AppRoutes.addMedication)
//
// Controller usage:
//   - Call medicalController.loadMedications(userId) in initState
//   - Checkbox tap → medicalController.markAsTaken (if implemented)
//
// Rules:
//   - StatefulWidget — checkbox state changes the progress counter
//   - Background color: AppColors.background
// ============================================================
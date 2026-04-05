// ============================================================
// profile_screen.dart
// User profile, personal details, goals, and settings screen.
//
// What to build:
//   - Blue header with AvatarWidget, user name, email, edit avatar button
//   - Personal Details card: age, weight, height with Edit button
//     Edit → showDialog with fields → profileController.updatePersonalDetails(...)
//   - Daily Goals card: calories goal, water goal with Edit button
//     Edit → showDialog with fields → profileController.updateGoals(...)
//   - Preferences section:
//       Dark mode toggle → profileController.toggleDarkMode() (if implemented)
//       Language setting (static for now)
//   - Workout History link → pushNamed(AppRoutes.workoutHistory)
//   - Logout CustomButton (red/outlined)
//     → Helpers.showConfirmDialog → profileController.logout(context)
//
// Controller usage:
//   - Call profileController.loadUser(userId) in initState
//
// Rules:
//   - StatefulWidget — dark mode toggle and edit dialogs change displayed values
//   - Background color: AppColors.background
// ============================================================
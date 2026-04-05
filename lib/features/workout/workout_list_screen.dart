// ============================================================
// workout_list_screen.dart
// Shows predefined workouts and user's own workouts.
//
// What to build:
//   - CustomAppBar title: 'Workouts'
//   - SectionHeader 'Predefined Workouts'
//   - Horizontal scrollable list of WorkoutCards (isPredefined: true)
//     each card has Start button → startSession then pushNamed(AppRoutes.workoutSession)
//     and View Details → Navigator.push with WorkoutModel to workout_overview_screen
//   - SectionHeader 'My Workouts'
//   - Vertical list of WorkoutCards (isPredefined: false)
//     each card has View Details and Edit buttons
//   - If my workouts list is empty → EmptyStateWidget
//   - FAB '+' → pushNamed(AppRoutes.createWorkout)
//
// Controller usage:
//   - Call workoutController.loadWorkouts(userId) in initState
//   - Show LoadingWidget while isLoading is true
//
// Rules:
//   - StatefulWidget — list can change when user creates or deletes a workout
//   - Background color: AppColors.background
// ============================================================
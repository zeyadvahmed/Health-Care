// ============================================================
// section_header.dart
// Row with a bold section title on the left and optional
// "See All" or "View All" button on the right.
//
// Usage:
//   SectionHeader(title: 'My Workouts')
//   SectionHeader(
//     title: 'Recent Sessions',
//     onSeeAll: () => Navigator.pushNamed(context, AppRoutes.workoutHistory),
//   )
//
// Parameters:
//   title    — section title text (required)
//   onSeeAll — optional callback, if provided shows "See All" button on right
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Title uses AppTheme titleMedium or titleLarge text style
//   - See All button uses AppColors.steelColor text color
//   - Full width row with space between title and button
// ============================================================
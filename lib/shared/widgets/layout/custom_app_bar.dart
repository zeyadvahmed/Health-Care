// ============================================================
// custom_app_bar.dart
// Reusable AppBar used at the top of all feature screens.
//
// Usage:
//   CustomAppBar(title: 'Workout')
//   CustomAppBar(
//     title: 'Create Workout',
//     showBackButton: true,
//   )
//   CustomAppBar(
//     title: 'Profile',
//     showBackButton: false,
//     actions: [
//       IconButton(icon: Icon(Icons.edit), onPressed: () {}),
//     ],
//   )
//
// Parameters:
//   title          — screen title text (required)
//   showBackButton — shows back arrow on the left, defaults to true
//   actions        — optional list of action widgets on the right
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Implement PreferredSizeWidget so it works as AppBar in Scaffold
//   - Use AppTheme appBarTheme as base style
//   - Back button calls Navigator.pop(context)
// ============================================================
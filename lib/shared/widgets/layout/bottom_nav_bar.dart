// ============================================================
// bottom_nav_bar.dart
// Four-tab bottom navigation bar persistent across main screens.
//
// Usage:
//   BottomNavBar(
//     currentIndex: _currentIndex,
//     onTap: (index) => setState(() => _currentIndex = index),
//   )
//
// Parameters:
//   currentIndex — index of the currently active tab (required)
//   onTap        — callback fired with new index when tab is tapped (required)
//
// Tabs (in order):
//   0 — Home     (Icons.home)
//   1 — Progress (Icons.bar_chart)
//   2 — Activity (Icons.bolt)
//   3 — Profile  (Icons.person)
//
// Rules:
//   - StatelessWidget — active index managed by parent (home_screen)
//   - Use AppTheme bottomNavigationBarTheme as base style
//   - Active tab color: AppColors.steelColor
//   - Inactive tab color: AppColors.textSecondary
// ============================================================
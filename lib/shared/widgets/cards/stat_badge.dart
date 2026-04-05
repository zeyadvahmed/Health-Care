// ============================================================
// stat_badge.dart
// Small card showing one statistic with an icon, label, and value.
// Used in summary screens and overview cards.
//
// Usage:
//   StatBadge(
//     label: 'Duration',
//     value: '45 min',
//     icon: Icons.timer,
//     color: AppColors.steelColor,
//   )
//   StatBadge(
//     label: 'Volume',
//     value: '3,200 kg',
//     icon: Icons.fitness_center,
//     color: AppColors.workoutColor,
//   )
//
// Parameters:
//   label — stat name shown below the value (required)
//   value — stat value shown prominently in center (required)
//   icon  — icon shown above the value (required)
//   color — icon and accent color for this stat (required)
//
// Rules:
//   - StatelessWidget — displays fixed passed-in data, no internal state
//   - Card background: AppColors.cardBackground
//   - Value text: AppTheme titleMedium, AppColors.textPrimary
//   - Label text: AppTheme bodySmall, AppColors.textSecondary
//   - Icon color matches the color parameter
//   - Rounded card with consistent padding
// ============================================================
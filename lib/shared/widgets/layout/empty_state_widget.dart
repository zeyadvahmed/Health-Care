// ============================================================
// empty_state_widget.dart
// Centered placeholder shown when a list or screen has no data.
//
// Usage:
//   EmptyStateWidget(
//     message: 'No workouts yet',
//     icon: Icons.fitness_center,
//   )
//   EmptyStateWidget(
//     message: 'No meals logged today',
//     icon: Icons.restaurant,
//     actionLabel: 'Add Food',
//     onAction: () => _showAddFoodSheet(context),
//   )
//
// Parameters:
//   message     — main message text shown below the icon (required)
//   icon        — icon shown above the message (required)
//   actionLabel — optional label for action button below message
//   onAction    — callback for the action button, required if actionLabel is set
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Centered vertically and horizontally in its parent
//   - Icon color: AppColors.textSecondary
//   - Message style: AppTheme bodyMedium in AppColors.textSecondary
//   - Action button uses CustomButton with isOutlined: true
// ============================================================
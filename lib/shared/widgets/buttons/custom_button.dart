// ============================================================
// custom_button.dart
// Reusable primary action button used across the entire app.
//
// Usage:
//   CustomButton(
//     label: 'Save Workout',
//     onPressed: () => controller.save(),
//   )
//   CustomButton(
//     label: 'Cancel',
//     isOutlined: true,
//     onPressed: () => Navigator.pop(context),
//   )
//   CustomButton(
//     label: 'Loading...',
//     isLoading: true,
//     onPressed: null,
//   )
//
// Parameters:
//   label      — text displayed inside the button (required)
//   onPressed  — callback when tapped, pass null to disable (required)
//   isLoading  — shows CircularProgressIndicator instead of label
//   isOutlined — renders as outlined border style instead of filled
//   color      — override button color, defaults to AppColors.steelColor
//   width      — override button width, defaults to full width
//
// Rules:
//   - Always use AppColors for colors, never raw hex
//   - Use AppTheme button style as the base, only override when needed
//   - StatelessWidget — no internal state needed
// ============================================================
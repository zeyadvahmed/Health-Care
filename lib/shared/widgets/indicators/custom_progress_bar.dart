// ============================================================
// custom_progress_bar.dart
// Styled linear progress bar with optional label and percentage.
//
// Usage:
//   CustomProgressBar(
//     value: 0.75,
//     color: AppColors.workoutColor,
//     label: 'Progress',
//     showPercentage: true,
//   )
//   CustomProgressBar(
//     value: session.progress,
//     color: AppColors.steelColor,
//   )
//
// Parameters:
//   value          — fill amount from 0.0 to 1.0 (required)
//   color          — bar fill color (required)
//   label          — optional text shown above the bar on the left
//   showPercentage — shows percentage number on the right of the label row
//
// Rules:
//   - StatelessWidget — value is passed in, no internal state
//   - Clamp value between 0.0 and 1.0 to avoid overflow errors
//   - Rounded bar ends using BorderRadius
//   - Background track color should be AppColors.cardBackground
// ============================================================
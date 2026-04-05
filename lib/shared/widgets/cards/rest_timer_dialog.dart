// ============================================================
// rest_timer_dialog.dart
// Countdown dialog shown after a set is completed during a session.
// Counts down from restSeconds to zero, then auto-dismisses.
//
// Usage:
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => RestTimerDialog(
//       seconds: 60,
//       onSkip: () => Navigator.pop(context),
//       onReset: () { /* restart countdown */ },
//     ),
//   )
//
// Parameters:
//   seconds  — rest duration in seconds, from exercise.restSeconds (required)
//   onSkip   — callback when user taps Skip button (required)
//   onReset  — callback when user taps Reset button (required)
//
// What to build:
//   - Large countdown number in center
//   - Circular progress ring around the number depleting as time passes
//   - Skip button and Reset button below
//   - Auto-dismiss and call onSkip when countdown reaches zero
//
// Rules:
//   - StatefulWidget — countdown ticks every second using Timer.periodic
//   - Cancel Timer in dispose() to avoid memory leaks
//   - Countdown color: AppColors.steelColor
//   - Background: AppColors.cardBackground
// ============================================================
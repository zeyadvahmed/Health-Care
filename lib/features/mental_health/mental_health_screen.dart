// ============================================================
// mental_health_screen.dart
// Mood logging and mental wellness screen.
//
// What to build:
//   - CustomAppBar title: 'Mental Health'
//   - MoodSelector widget → on select calls mentalHealthController.saveMood(...)
//   - Mood history bar chart for last 7 days using mentalHealthController.lastSevenDays
//   - Daily reflection CustomTextField (multiline)
//   - Save Note CustomButton → saves note with current mood
//   - Guided exercises section with two cards:
//       '4-7-8 Breathing' and 'Deep Meditation' with play buttons
//       (play buttons can show a simple instructions dialog for now)
//   - Daily tips cards at the bottom (static content is fine)
//
// Controller usage:
//   - Call mentalHealthController.loadMoodHistory(userId) in initState
//
// Rules:
//   - StatefulWidget — mood selection, chart updates after save
//   - Background color: AppColors.background
// ============================================================
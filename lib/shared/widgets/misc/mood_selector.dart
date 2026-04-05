// ============================================================
// mood_selector.dart
// Row of four mood icon buttons — Happy, Calm, Tired, Stressed.
// The selected mood is visually highlighted.
//
// Usage:
//   MoodSelector(
//     selectedMood: _selectedMood,
//     onMoodSelected: (mood) => setState(() => _selectedMood = mood),
//   )
//
// Parameters:
//   selectedMood    — currently selected mood string, null if none selected (required)
//   onMoodSelected  — callback fired with the mood string when user taps one (required)
//
// Mood values and icons:
//   "happy"    — 😊 or Icons.sentiment_very_satisfied
//   "calm"     — 😌 or Icons.self_improvement
//   "tired"    — 😴 or Icons.bedtime
//   "stressed" — 😤 or Icons.sentiment_very_dissatisfied
//
// Rules:
//   - StatelessWidget — selected state managed by parent, not internally
//   - Selected mood circle: AppColors.steelColor background, white icon
//   - Unselected mood circle: AppColors.cardBackground, AppColors.textSecondary icon
//   - All four circles equal size, evenly spaced in a Row
//   - Show mood label text below each icon
// ============================================================
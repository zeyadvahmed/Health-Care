// ============================================================
// mental_health_controller.dart
// Manages mood entries and reflection notes.
//
// Usage:
//   final controller = MentalHealthController();
//   await controller.loadMoodHistory(userId);
//   await controller.saveMood(userId, 'happy', note: 'Felt great today');
//
// State to expose:
//   bool isLoading                       — true while loading
//   List<MoodEntryModel> lastSevenDays   — mood entries for bar chart
//   MoodEntryModel? latestEntry          — most recent mood entry
//
// Methods to implement:
//   loadMoodHistory(String userId)       — load last 7 days from SQLite
//   saveMood(String userId, String mood, — insert mood entry with optional note,
//            {String? note})               call sync after saving
//
// Rules:
//   - Always call sync_service.syncAll() after saving
//   - No Flutter UI imports except material.dart if needed
// ============================================================
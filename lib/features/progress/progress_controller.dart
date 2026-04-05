// ============================================================
// progress_controller.dart
// Loads all chart and stats data for the progress screen.
//
// Usage:
//   final controller = ProgressController();
//   await controller.loadProgressData(userId);
//
// State to expose:
//   bool isLoading                        — true while loading
//   int thisWeekWorkouts                  — count of sessions this week
//   int totalWorkouts                     — all time session count
//   List<WorkoutSessionModel> activityData— sessions for line chart
//   int avgDailyCalories                  — average kcal per day this week
//   List<HydrationEntryModel> weekHydration — entries for weekly bar chart
//   List<MoodEntryModel> moodTrend        — last 7 days for mood area chart
//
// Methods to implement:
//   loadProgressData(String userId)       — load all data above from SQLite
//                                           in parallel using Future.wait
//
// Rules:
//   - All reads from SQLite only — no Firestore calls
//   - Use Future.wait to load all data concurrently, not sequentially
//   - No Flutter UI imports except material.dart if needed
// ============================================================
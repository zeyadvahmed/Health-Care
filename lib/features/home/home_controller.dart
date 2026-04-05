// ============================================================
// home_controller.dart
// Loads all data shown on the home dashboard screen.
//
// Usage:
//   final controller = HomeController();
//   await controller.loadHomeData(userId);
//
// State to expose:
//   bool isLoading              — true while loading data
//   UserModel? user             — current user for greeting and goals
//   WorkoutModel? todayWorkout  — today's scheduled or last workout
//   int todayWaterMl            — total water logged today in ml
//   MoodEntryModel? latestMood  — most recent mood entry for mood card
//
// Methods to implement:
//   loadHomeData(String userId)  — loads all of the above from SQLite in parallel
//                                  sets isLoading false when done
//
// Rules:
//   - All reads from SQLite only — never calls Firestore directly
//   - Used only by home_screen
//   - No Flutter UI imports except material.dart for ChangeNotifier if used
// ============================================================
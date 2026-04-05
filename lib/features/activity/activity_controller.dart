// ============================================================
// activity_controller.dart
// Loads and exposes XP and level data for the activity screen.
//
// Usage:
//   final controller = ActivityController();
//   await controller.loadActivity(userId);
//
// State to expose:
//   bool isLoading            — true while loading
//   ActivityModel? activity   — current XP and level data
//   bool didLevelUp           — true if user leveled up since last check
//                               used by activity_screen to show level_up_dialog
//
// Methods to implement:
//   loadActivity(String userId)   — load activity record from SQLite
//                                   if no record exists yet, show zero state
//   checkLevelUp()                — compare currentLevel before and after
//                                   last XP award, set didLevelUp flag
//
// Rules:
//   - XP is awarded by workout_controller — this controller only reads
//   - didLevelUp resets to false after activity_screen shows the dialog
//   - No Flutter UI imports except material.dart if needed
// ============================================================
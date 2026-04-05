// ============================================================
// hydration_controller.dart
// Manages water intake entries and daily total.
//
// Usage:
//   final controller = HydrationController();
//   await controller.loadTodayData(userId);
//   await controller.addWater(userId, 250, '250ml', goalMl);
//   await controller.addWater(userId, 500, '500ml', goalMl);
//
// State to expose:
//   bool isLoading                         — true while loading
//   int totalMlToday                       — sum of all entries today
//   List<HydrationEntryModel> entries      — today's entries for history list
//   double progressPercent                 — totalMlToday / dailyGoalMl clamped to 1.0
//
// Methods to implement:
//   loadTodayData(String userId)           — load total and entries from SQLite
//   addWater(String userId, int amountMl,  — insert entry, update total and percent,
//            String type, int goalMl)        call sync
//   deleteEntry(String id)                 — delete entry, recalculate total, call sync
//
// Rules:
//   - Always call sync_service.syncAll() after every change
//   - progressPercent must clamp between 0.0 and 1.0
//   - No Flutter UI imports except material.dart if needed
// ============================================================
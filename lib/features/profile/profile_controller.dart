// ============================================================
// profile_controller.dart
// Manages user profile data, goals, and settings.
//
// Usage:
//   final controller = ProfileController();
//   await controller.loadUser(userId);
//   await controller.updatePersonalDetails(userId, age, weight, height);
//   await controller.updateGoals(userId, caloriesGoal, waterGoal);
//   await controller.logout(context);
//
// State to expose:
//   bool isLoading       — true while loading or saving
//   UserModel? user      — current user data for display
//
// Methods to implement:
//   loadUser(String userId)                           — load user from SQLite
//   updatePersonalDetails(String userId, int age,     — update user fields in SQLite,
//     double weight, double height)                     call sync
//   updateGoals(String userId, int caloriesGoal,      — update goal fields in SQLite,
//     int waterGoal)                                    call sync
//   logout(BuildContext context)                      — call auth_service.signOut,
//                                                       navigate to LoginScreen using
//                                                       pushNamedAndRemoveUntil
//
// Rules:
//   - Always call sync_service.syncAll() after every update
//   - logout uses pushNamedAndRemoveUntil to clear navigation stack
//   - No Flutter UI imports except material.dart for BuildContext
// ============================================================
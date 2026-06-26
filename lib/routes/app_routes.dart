// ============================================================
// app_routes.dart
// Centralized navigation for the entire SparkSteel app.
//
// HOW TO NAVIGATE:
//   Simple screen (no data needed):
//     Navigator.pushNamed(context, AppRoutes.login)
//
//   Replace current screen:
//     Navigator.pushReplacementNamed(context, AppRoutes.home)
//
//   Clear stack (logout, session end):
//     Navigator.pushNamedAndRemoveUntil(
//       context, AppRoutes.home, (route) => false)
//
//   Screens marked [PASS DATA] below CANNOT be in this routes
//   map because they require constructor arguments. Always use:
//     Navigator.push(context, MaterialPageRoute(
//       builder: (_) => WorkoutOverviewScreen(workout: w),
//     ));
//
// SCREENS NOT IN THIS FILE (not built yet):
//   workout_history_screen.dart   → add when built
//   active_session_screen         → PASS DATA, not in map
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparlsteel/features/workout/workout_list_screen.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/workout/create_workout_screen.dart';
import '../features/workout/exercise_search_screen.dart';
import '../features/nutrition/ui/nutrition_screen.dart';
import '../features/hydration/hydration_screen.dart';
import '../features/mental_health/ui/mental_health_screen.dart';
import '../features/medical_tracker/ui/medical_tracker_screen.dart';
import '../features/medical_tracker/ui/add_medication_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/activity/activity_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/chatbot/chatbot_screen.dart';

// Screens below are imported but NOT registered in the routes
// map — they require constructor params (PASS DATA pattern).
// They are imported here only so the constants below can be
// used as identifiers in Navigator.pushNamedAndRemoveUntil.
// ignore_for_file: unused_import

class AppRoutes {
  // ── Auth ───────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // ── Main Navigation ────────────────────────────────────────
  static const String home = '/home';
  static const String progress = '/progress';
  static const String activity = '/activity';
  static const String profile = '/profile';

  // ── Workout ────────────────────────────────────────────────
  static const String workoutList = '/workouts';
  static const String createWorkout = '/workouts/create';
  static const String exerciseSearch = '/workouts/exercise-search';
  static const String workoutHistory = '/workouts/history';

  // The following are PASS DATA routes — use Navigator.push only:
  //   addExercise     → AddExerciseScreen(workoutId)
  //   workoutOverview → WorkoutOverviewScreen(workout, userId)
  //   workoutSession  → ActiveSessionScreen(session, workout, exercises, userId)
  //   workoutSummary  → WorkoutSummaryScreen(session, logs, userId)
  static const String addExercise = '/workouts/add-exercise';
  static const String workoutOverview = '/workouts/overview';
  static const String workoutSession = '/workouts/session';
  static const String workoutSummary = '/workouts/summary';

  // ── Nutrition ──────────────────────────────────────────────
  static const String nutrition = '/nutrition';

  // ── Hydration ──────────────────────────────────────────────
  static const String hydration = '/hydration';

  // ── Mental Health ──────────────────────────────────────────
  static const String mentalHealth = '/mental-health';

  // ── Medical ────────────────────────────────────────────────
  static const String medicalTracker = '/medical';
  static const String addMedication = '/medical/add';

  // ── Chatbot ────────────────────────────────────────────────
  static const String chatbot = '/chatbot';

  // ── Routes Map ─────────────────────────────────────────────
  // ONLY screens that need NO constructor arguments go here.
  // PASS DATA screens (workoutOverview, workoutSession,
  // workoutSummary, addExercise) are excluded — they must be
  // navigated to via Navigator.push + MaterialPageRoute.
  static Map<String, WidgetBuilder> get routes => {
    // Auth
    splash: (_) => const SplashScreen(),
    login: (_) => LoginScreen(),
    signup: (_) => const SignupScreen(),

    // Main navigation
    home: (_) => const HomeScreen(),
    progress: (_) => const ProgressScreen(),
    activity: (_) => const ActivityScreen(),
    profile: (_) => const ProfileScreen(),

    // Workout — only screens that need no args
    workoutList: (_) => const WorkoutListScreen(),
    createWorkout: (_) => const CreateWorkoutScreen(userId: ''),
    exerciseSearch: (_) => const ExerciseSearchScreen(),
    // workoutHistory: add here when WorkoutHistoryScreen is built

    // Nutrition
    nutrition: (_) => const NutritionScreen(),

    // Hydration
    hydration: (_) => const HydrationScreen(),

    // Mental health
    mentalHealth: (_) => const MentalHealthScreen(),

    // Medical
    medicalTracker: (_) => const MedicalTrackerScreen(),
    addMedication: (_) => const AddMedicationScreen(),

    // Chatbot
    chatbot: (_) => const ChatbotScreen(),
  };
}

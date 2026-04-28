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
//   Go back:
//     Navigator.pop(context)
//
//   Screens marked with [PASS DATA] below need data passed.
//   Use Navigator.push + MaterialPageRoute for those screens.
//   Example:
//     Navigator.push(context, MaterialPageRoute(
//       builder: (_) => WorkoutOverviewScreen(workout: workout),
//     ));
// ============================================================

import 'package:flutter/material.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/workout/workout_list_screen.dart';
import '../features/workout/create_workout_screen.dart';
import '../features/workout/add_exercise_screen.dart';
import '../features/workout/exercise_search_screen.dart';
import '../features/workout/workout_overview_screen.dart';
import '../features/workout/workout_session_screen.dart';
import '../features/workout/workout_summary_screen.dart';
import '../features/workout/workout_history_screen.dart';
import '../features/nutrition/ui/nutrition_screen.dart';
import '../features/hydration/hydration_screen.dart';
import '../features/mental_health/ui/mental_health_screen.dart';
import '../features/medical_tracker/medical_tracker_screen.dart';
import '../features/medical_tracker/add_medication_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/activity/activity_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/chatbot/chatbot_screen.dart';

class AppRoutes {

  // ── Auth ───────────────────────────────────────────────────
  static const String splash  = '/';
  static const String login   = '/login';
  static const String signup  = '/signup';

  // ── Main Navigation ────────────────────────────────────────
  static const String home     = '/home';
  static const String progress = '/progress';
  static const String activity = '/activity';
  static const String profile  = '/profile';

  // ── Workout ────────────────────────────────────────────────
  static const String workoutList     = '/workouts';
  static const String createWorkout   = '/workouts/create';
  static const String addExercise     = '/workouts/add-exercise';   // [PASS DATA] receives WorkoutModel
  static const String exerciseSearch  = '/workouts/exercise-search';
  static const String workoutOverview = '/workouts/overview';       // [PASS DATA] receives WorkoutModel
  static const String workoutSession  = '/workouts/session';        // [PASS DATA] receives WorkoutModel + exercises
  static const String workoutSummary  = '/workouts/summary';        // [PASS DATA] receives WorkoutSessionModel
  static const String workoutHistory  = '/workouts/history';

  // ── Nutrition ──────────────────────────────────────────────
  static const String nutrition = '/nutrition';

  // ── Hydration ──────────────────────────────────────────────
  static const String hydration = '/hydration';

  // ── Mental Health ──────────────────────────────────────────
  static const String mentalHealth = '/mental-health';

  // ── Medical ────────────────────────────────────────────────
  static const String medicalTracker  = '/medical';
  static const String addMedication   = '/medical/add';

  // ── Chatbot ────────────────────────────────────────────────
  static const String chatbot = '/chatbot';

  // ── Routes Map ────────────────────────────────────────────
  // Connects every route string to its screen widget.
  // This map is passed to MaterialApp routes: parameter in app.dart.
  // Every route string above must have an entry here.
  static Map<String, WidgetBuilder> get routes => {

    // Auth
    splash  : (_) => const SplashScreen(),
    login   : (_) => const LoginScreen(),
    signup  : (_) => const SignupScreen(),

    // Main navigation
    home     : (_) => const HomeScreen(),
    progress : (_) => const ProgressScreen(),
    activity : (_) => const ActivityScreen(),
    profile  : (_) => const ProfileScreen(),

    // Workout
    // Note: workoutOverview, workoutSession, workoutSummary
    // are registered here for completeness but use
    // Navigator.push + MaterialPageRoute when passing data.
    workoutList     : (_) => const WorkoutListScreen(),
    createWorkout   : (_) => const CreateWorkoutScreen(),
    addExercise     : (_) => const AddExerciseScreen(),
    exerciseSearch  : (_) => const ExerciseSearchScreen(),
    workoutOverview : (_) => const WorkoutOverviewScreen(),
    workoutSession  : (_) => const WorkoutSessionScreen(),
    workoutSummary  : (_) => const WorkoutSummaryScreen(),
    workoutHistory  : (_) => const WorkoutHistoryScreen(),

    // Nutrition
    nutrition : (_) => const NutritionScreen(),

    // Hydration
    hydration : (_) => const HydrationScreen(),

    // Mental health
    mentalHealth : (_) => const MentalHealthScreen(),

    // Medical
    medicalTracker : (_) => const MedicalTrackerScreen(),
    addMedication  : (_) => const AddMedicationScreen(),

    // Chatbot
    chatbot : (_) => const ChatbotScreen(),
  };
}
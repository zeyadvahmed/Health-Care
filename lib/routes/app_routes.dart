// ============================================================
// app_routes.dart
// Centralized navigation for the entire SparkSteel app.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/features/mental_health/logic/mental_cubit.dart';
import 'package:sparksteel/features/nutrition/nutrition_cubit.dart';

import '../features/activity/cubit/activity_cubit.dart';
import '../features/activity/ui/activity_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/home/home_screen.dart';
import '../features/hydration/cubit/hydration_cubit.dart';
import '../features/hydration/ui/hydration_screen.dart';
import '../features/medical_tracker/cubit/medical_cubit.dart';
import '../features/medical_tracker/ui/add_medication_screen.dart';
import '../features/medical_tracker/ui/medical_tracker_screen.dart';
import '../features/mental_health/ui/mental_health_screen.dart';
import '../features/nutrition/ui/nutrition_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/workout/create_workout_screen.dart';
import '../features/workout/exercise_search_screen.dart';
import '../features/workout/workout_list_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/home';
  static const String progress = '/progress';
  static const String activity = '/activity';
  static const String profile = '/profile';

  static const String workoutList = '/workouts';
  static const String createWorkout = '/workouts/create';
  static const String addExercise = '/workouts/add-exercise';
  static const String exerciseSearch = '/workouts/exercise-search';
  static const String workoutOverview = '/workouts/overview';
  static const String workoutSession = '/workouts/session';
  static const String workoutSummary = '/workouts/summary';
  static const String workoutHistory = '/workouts/history';

  static const String nutrition = '/nutrition';
  static const String hydration = '/hydration';
  static const String mentalHealth = '/mental-health';
  static const String medicalTracker = '/medical';
  static const String addMedication = '/medical/add';
  static const String chatbot = '/chatbot';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) =>  LoginScreen(),
    signup: (_) => const SignupScreen(),

    home: (_) => const HomeScreen(),
    progress: (_) => const ProgressScreen(),
    activity: (_) => BlocProvider(
      create: (context) => ActivityCubit(),
      child: const ActivityScreen(
        userId: '',
        uid: '',
        userName: '',
      ),
    ),
    profile: (_) => const ProfileScreen(),

    workoutList: (_) => const WorkoutListScreen(),
    createWorkout: (_) => const CreateWorkoutScreen(userId: ''),
    exerciseSearch: (_) => const ExerciseSearchScreen(),

    nutrition: (_) => BlocProvider(
      create: (context) => NutritionCubit()
        ..getMealsForDateAndMeal(
          DateTime.now().toString().substring(0, 10),
          'Breakfast',
        )
        ..getMealsForDateAndMeal(
          DateTime.now().toString().substring(0, 10),
          'Lunch',
        )
        ..getMealsForDateAndMeal(
          DateTime.now().toString().substring(0, 10),
          'Dinner',
        )
        ..getMealsForDateAndMeal(
          DateTime.now().toString().substring(0, 10),
          'Snack',
        )
        ..getTotalcalories(DateTime.now().toString().substring(0, 10)),
      child: const NutritionScreen(),
    ),

    hydration: (_) => BlocProvider(
      create: (context) => HydrationCubit(),
      child: const HydrationScreen(userId: '', uid: ''),
    ),
    mentalHealth: (_) => BlocProvider(
      create: (context) => MentalCubit()..getGuidedExercises(),
      child: const MentalHealthScreen(),
    ),

    medicalTracker: (_) => BlocProvider(
      create: (context) => MedicalCubit(),
      child: const MedicalTrackerScreen(userId: '', uid: ''),
    ),
    addMedication: (_) => BlocProvider(
      create: (context) => MedicalCubit(),
      child: const AddMedicationScreen(userId: '', uid: ''),
    ),

    chatbot: (_) => const ChatbotScreen(),
  };
}

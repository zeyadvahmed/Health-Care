// ============================================================
// main.dart
// Entry point for the SparkSteel application.
//
// Responsibilities:
//   1. Initialize Flutter bindings
//   2. Initialize Firebase
//   3. Open SQLite database (DatabaseHelper.instance.database)
//   4. Lock device orientation to portrait
//   5. Register all Cubits via MultiBlocProvider
//   6. Launch SparkSteelApp
//
// State management:
//   All cubits are created here and injected into the widget
//   tree via MultiBlocProvider. Screens access them via
//   context.read<ControllerName>() or BlocBuilder.
//
// Add new cubits here as each feature is built:
//   BlocProvider(create: (_) => AuthController()),
//   BlocProvider(create: (_) => NutritionController()),
//   etc.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'data/local/database_helper.dart';
import 'features/workout/workout_controller.dart';
import 'app.dart';

void main() async {
  // Required before any async work in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with auto-generated options.
  // Run 'flutterfire configure' to regenerate firebase_options.dart.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Open SQLite database on app start.
  // This creates sparksteel.db and all 12 tables on first launch.
  // Every local service will reuse this open connection.
  await DatabaseHelper.instance.database;

  // Lock orientation to portrait — SparkSteel is portrait-only.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // MultiBlocProvider registers all Cubits at the root of the
    // widget tree so every screen can access them via context.read().
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkoutController()),
        // Add more as each feature controller is built:
        // BlocProvider(create: (_) => AuthController()),
        // BlocProvider(create: (_) => HomeController()),
        // BlocProvider(create: (_) => NutritionController()),
        // BlocProvider(create: (_) => HydrationController()),
        // BlocProvider(create: (_) => MentalHealthController()),
        // BlocProvider(create: (_) => MedicalController()),
        // BlocProvider(create: (_) => ActivityController()),
        // BlocProvider(create: (_) => ProgressController()),
        // BlocProvider(create: (_) => ChatbotController()),
        // BlocProvider(create: (_) => ProfileController()),
      ],
      child: const SparkSteelApp(),
    ),
  );
}

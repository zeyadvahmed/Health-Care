// ============================================================
// main.dart
// Entry point for the SparkSteel application.
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/data/local/database_helper.dart';
import 'package:sparksteel/data/sync/connectivity_service.dart';
import 'package:sparksteel/data/sync/sync_service.dart';
import 'package:sparksteel/features/workout/workout_controller.dart';
import 'package:sparksteel/firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseHelper.instance.database;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _startBackgroundSync();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkoutController()),
      ],
      child: const SparkSteelApp(),
    ),
  );
}

void _startBackgroundSync() {
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      SyncService.instance.syncAll(user.uid);
    }
  });

  ConnectivityService.instance.onConnectivityChanged.listen((isOnline) {
    final user = FirebaseAuth.instance.currentUser;
    if (isOnline && user != null) {
      SyncService.instance.syncAll(user.uid);
    }
  });
}

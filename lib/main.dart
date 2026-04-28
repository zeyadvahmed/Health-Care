// ============================================================
// main.dart
// Entry point of the SparkSteel application.
//
// Responsibilities:
//   1. Ensure Flutter engine is ready before doing anything
//   2. Initialize Firebase (Auth + Firestore)
//   3. Initialize the local SQLite database
//   4. Run the app
// ============================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sparksteel/firebase_options.dart';

import 'app.dart';

void main() async {
  // ── Step 1: Must be called before any async work ──────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── Step 2: Lock app to portrait mode ─────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Step 3: Initialize Firebase ───────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Step 4: Initialize SQLite database ────────────────────
  // This creates all tables on first launch.
  // Must be done before any screen tries to read/write data.
  await DatabaseHelper.instance.database;

  // ── Step 5: Run the app ───────────────────────────────────
  runApp(const SparkSteelApp());
}

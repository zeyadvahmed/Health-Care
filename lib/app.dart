// ============================================================
// app.dart
// Root widget of the SparkSteel application.
//
// Responsibilities:
//   1. Create the MaterialApp
//   2. Connect the global theme (AppTheme)
//   3. Connect all named routes (AppRoutes)
//   4. Set the starting screen (SplashScreen)
//   5. Handle dark mode based on user preference
// ============================================================

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'routes/app_routes.dart';
import 'features/auth/splash_screen.dart';

class SparkSteelApp extends StatelessWidget {
  const SparkSteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── App identity ───────────────────────────────────────
      title: '${AppStrings.appFname}${AppStrings.appLname}',

      // ── Hide the debug banner ──────────────────────────────
      debugShowCheckedModeBanner: false,

      // ── Light theme ────────────────────────────────────────
      // All colors, buttons, text, inputs styled here.
      // Team widgets pick up correct style automatically.
      theme: AppTheme.lightTheme,

      // ── Dark theme ─────────────────────────────────────────
      // Activated when user toggles dark mode in Profile.
      darkTheme: AppTheme.darkTheme,

      // ── Theme mode ─────────────────────────────────────────
      // Follows device setting by default.
      // ProfileController changes this when user toggles.
      themeMode: ThemeMode.system,

      // ── Starting screen ────────────────────────────────────
      // SplashScreen checks Firebase auth state:
      //   logged in  → HomeScreen
      //   logged out → LoginScreen
      //   checking   → splash UI
      home: const SplashScreen(),

      // ── All named routes ───────────────────────────────────
      // Every screen registered here.
      // Use Navigator.pushNamed(context, AppRoutes.x) anywhere.
      routes: AppRoutes.routes,

      // ── Unknown route fallback ─────────────────────────────
      // Shows error screen instead of crashing.
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const _RouteNotFoundScreen()),
    );
  }
}

// ============================================================
// _RouteNotFoundScreen
// Only shown if navigation is called with a wrong route name.
// ============================================================
class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF082644),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check AppRoutes for the correct route name.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Color(0xFF137FEC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

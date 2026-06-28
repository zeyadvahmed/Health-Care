// ============================================================
// app.dart
// Root widget of the SparkSteel application.
// ============================================================

import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

class SparkSteelApp extends StatelessWidget {
  const SparkSteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppStrings.appFname}${AppStrings.appLname}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const _RouteNotFoundScreen()),
    );
  }
}

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

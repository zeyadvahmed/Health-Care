// ============================================================
// splash_screen.dart
// First screen the app opens. Checks auth state and navigates accordingly.
// ============================================================

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

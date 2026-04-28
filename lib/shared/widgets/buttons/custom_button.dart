// ============================================================
// custom_button.dart
// Reusable primary action button used across the entire app.
//
// Usage:
//   CustomButton(
//     label: 'Save Workout',
//     onPressed: () => controller.save(),
//   )
//   CustomButton(
//     label: 'Cancel',
//     isOutlined: true,
//     onPressed: () => Navigator.pop(context),
//   )
//   CustomButton(
//     label: 'Loading...',
//     isLoading: true,
//     onPressed: null,
//   )
//
// Parameters:
//   label      — text displayed inside the button (required)
//   onPressed  — callback when tapped, pass null to disable (required)
//   isLoading  — shows CircularProgressIndicator instead of label
//   isOutlined — renders as outlined border style instead of filled
//   color      — override button color, defaults to AppColors.steelColor
//   width      — override button width, defaults to full width
//
// Rules:
//   - Always use AppColors for colors, never raw hex
//   - Use AppTheme button style as the base, only override when needed
//   - StatelessWidget — no internal state needed
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  String label;
  VoidCallback? onPressed;
  CustomButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Color(0xff137FEC), // Replace with AppColors.steelColor
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
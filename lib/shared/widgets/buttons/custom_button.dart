// ============================================================
// custom_button.dart
// lib/shared/widgets/buttons/custom_button.dart
//
// PURPOSE:
//   The single reusable action button used across the whole app.
//   Used for: Login, Save Workout, Start Workout, Save Note,
//             Save Medication, Collect XP, Save and Exit.
//
// STATES:
//   Normal   → filled blue button with white label text
//   Loading  → spinner replaces label, button is still tappable
//   Outlined → transparent with blue border and blue label
//   Disabled → pass onPressed: null → automatic grey style
//
// RULES:
//   - StatelessWidget — all state passed in as parameters
//   - Use AppColors for all colors — never hardcode Color()
//   - Use AppTheme button style as base
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';


class CustomButton extends StatelessWidget {
  // The text displayed inside the button
  final String label;

  // What happens when tapped. Pass null to disable the button.
  final VoidCallback? onPressed;

  // When true: shows CircularProgressIndicator instead of label
  final bool isLoading;

  // When true: outlined border style instead of filled
  final bool isOutlined;

  // Override the default button color (defaults to steelColor)
  final Color? color;

  // Override the button width (defaults to full width)
  final double? width;

  // Override the button height (defaults to full width)
  final double? height;



  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Determine button color: use passed color or default steelColor
    final buttonColor = color ?? AppColors.steelColor;

    // The content inside the button — spinner or label
    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Spinner color: white on filled, blue on outlined
              color: isOutlined ? buttonColor : Colors.white,
            ),
          )
        : Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              // Text color: white on filled, blue on outlined
              color: isOutlined ? buttonColor : Colors.white,
            ),
          );

    // Container handles the optional width constraint
    return SizedBox(
      width: width ?? double.infinity, // full width by default
      height: height ?? 50,
      child: isOutlined
          // ── Outlined style ─────────────────────────────
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: buttonChild,
            )
          // ── Filled style ───────────────────────────────
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                // When disabled (onPressed=null) use dimmed color
                disabledBackgroundColor:
                    buttonColor.withValues(alpha: 0.4), // 40% opacity.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: buttonChild,
            ),
    );
  }
}
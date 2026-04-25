// ============================================================
// app_logo.dart
// lib/shared/widgets/misc/app_logo.dart
//
// PURPOSE:
//   SparkSteel brand logo widget used on auth screens.
//   Shows the app icon and optionally the app name.
//
// USED IN:
//   splash_screen, login_screen, signup_screen
//
// PARAMETERS:
//   size     — icon size, defaults to 64
//   showText — whether to show "SparkSteel" text, defaults to true
//
// TEXT RULE:
//   "Spark" → white bold
//   "Steel" → AppColors.steelColor bold
//   Both inline in one RichText
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // ── Icon ─────────────────────────────────────────────
        // Rounded square with sparkColor (navy) background
        // and a white bolt icon inside
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.steelColor,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),

        // ── Text ─────────────────────────────────────────────
        if (showText) ...[
          SizedBox(width: size * 0.2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Spark',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Steel',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.steelColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
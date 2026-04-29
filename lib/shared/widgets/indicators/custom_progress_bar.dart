// ============================================================
// custom_progress_bar.dart
// Styled linear progress bar with optional label and percentage.
//
// Usage:
//   CustomProgressBar(
//     value: 0.75,
//     color: AppColors.workoutColor,
//     label: 'Progress',
//     showPercentage: true,
//   )
//   CustomProgressBar(
//     value: session.progress,
//     color: AppColors.steelColor,
//   )
//
// Parameters:
//   value          — fill amount from 0.0 to 1.0 (required)
//   color          — bar fill color (required)
//   label          — optional text shown above the bar on the left
//   showPercentage — shows percentage number on the right of the label row
//
// Rules:
//   - StatelessWidget — value is passed in, no internal state
//   - Clamp value between 0.0 and 1.0 to avoid overflow errors
//   - Rounded bar ends using BorderRadius
//   - Background track color should be AppColors.cardBackground
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
  
class CustomProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final String? label;
  final bool showPercentage;
  
  const CustomProgressBar({
    super.key,
    required this.value,
    this.color,
    this.label,
    this.showPercentage = false,
  });
  
  double get _clamped => value.clamp(0.0, 1.0);
  
  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.steelColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _labelRow(barColor),
          const SizedBox(height: 6),
        ],
  
        Row(
          children: [
            Expanded(child: _bar(barColor)),
  
            if (showPercentage) ...[
              const SizedBox(width: 10),
              _percentageText(barColor),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _labelRow(Color barColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label!,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _bar(Color barColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                height: 8,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
  
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                height: 8,
                width: constraints.maxWidth * _clamped,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(8),
                  
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _percentageText(Color barColor) {
    final percent = (_clamped * 100).round();
    return SizedBox(
      width: 36,
      child: Text(
        '$percent%',
        style: TextStyle(
          color: barColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
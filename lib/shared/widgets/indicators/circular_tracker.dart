// ============================================================
// circular_tracker.dart
// Circular ring progress tracker showing current value vs goal.
// Used for water intake ring and calorie percentage ring.
//
// Usage:
//   CircularTracker(
//     current: 1500,
//     goal: 2500,
//     unit: 'ml',
//     color: AppColors.hydrationColor,
//   )
//   CircularTracker(
//     current: 1800,
//     goal: 2000,
//     unit: 'kcal',
//     color: AppColors.nutritionColor,
//   )
//
// Parameters:
//   current — current value (required)
//   goal    — target value (required)
//   unit    — unit string shown in center below the number (required)
//   color   — ring fill color (required)
//
// Rules:
//   - StatelessWidget — all values passed in, no internal state
//   - Show current value and unit in center of the ring
//   - Show percentage below or inside as secondary text
//   - Background ring color should be AppColors.cardBackground
//   - Clamp progress to 1.0 maximum so ring never overfills
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
  
class CircularTracker extends StatelessWidget {
  final num current;
  final num goal;
  final String unit;
  final Color color;
  
  const CircularTracker({
    super.key,
    required this.current,
    required this.goal,
    this.unit = 'ml',
    required this.color,
  });
  
  double get _progress {
    if (goal <= 0) return 0.0;
    return (current / goal).clamp(0.0, 1.0).toDouble();
  }
  
  @override
  Widget build(BuildContext context) {
    final arcColor = color;
  
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              arcColor.withOpacity(0.12),
            ),
          ),
  
          CircularProgressIndicator(
            value: _progress,
            strokeWidth: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(arcColor),
            strokeCap: StrokeCap.round,
          ),
  
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Text(
                  '$current',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
  
              
                Text(
                  unit,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
  
                
                _percentageChip(arcColor),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _percentageChip(Color arcColor) {
    final percent = (_progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: arcColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          color: arcColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

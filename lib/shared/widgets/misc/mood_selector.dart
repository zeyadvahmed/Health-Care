// ============================================================
// mood_selector.dart
// lib/shared/widgets/misc/mood_selector.dart
//
// PURPOSE:
//   Row of four mood buttons. The selected mood is highlighted.
//   Parent manages which mood is selected — this is StatelessWidget.
//
// USED IN:
//   mental_health_screen — primary mood logging
//   home_screen          — daily mood card
//
// PARAMETERS:
//   selectedMood   — currently selected mood string, null if none
//   onMoodSelected — callback fired with mood string on tap
//
// MOOD VALUES:
//   "happy"    → Icons.sentiment_very_satisfied_rounded
//   "calm"     → Icons.self_improvement_rounded
//   "tired"    → Icons.bedtime_rounded
//   "stressed" → Icons.sentiment_very_dissatisfied_rounded
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final void Function(String mood) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  // ----------------------------------------------------------
  // Mood data — each mood has a value, icon, label, and color.
  // Color is shown on the icon when selected.
  // ----------------------------------------------------------
  static const List<Map<String, dynamic>> _moods = [
    {
      'value': 'happy',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'label': 'Happy',
      'color': Color(0xFF4CAF50), // green
    },
    {
      'value': 'calm',
      'icon': Icons.self_improvement_rounded,
      'label': 'Calm',
      'color': Color(0xFF29B6F6), // sky blue
    },
    {
      'value': 'tired',
      'icon': Icons.bedtime_rounded,
      'label': 'Tired',
      'color': Color(0xFF7E57C2), // purple
    },
    {
      'value': 'stressed',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'label': 'Stressed',
      'color': Color(0xFFE53935), // red
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.map((mood) {
        final value    = mood['value']  as String;
        final icon     = mood['icon']   as IconData;
        final label    = mood['label']  as String;
        final color    = mood['color']  as Color;
        final selected = selectedMood == value;

        return GestureDetector(
          onTap: () => onMoodSelected(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Mood icon circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // Selected: colored background
                  // Unselected: light card background
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? color : AppColors.divider,
                    width: selected ? 2 : 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  // Selected: full mood color
                  // Unselected: muted grey
                  color: selected ? color : AppColors.textHint,
                ),
              ),

              const SizedBox(height: 6),

              // Mood label below icon
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selected ? color : AppColors.textHint,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
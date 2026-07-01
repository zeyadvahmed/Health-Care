import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/activity_challenge_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityChallengeModel challenge;

  const ActivityCard({
    super.key,
    required this.challenge,
  });

  IconData _iconData() {
    switch (challenge.type) {
      case 'hydration':
        return Icons.water_drop_rounded;
      case 'nutrition':
        return Icons.restaurant_rounded;
      case 'workout':
        return Icons.fitness_center_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'medication':
        return Icons.medication_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _iconColor() {
    if (challenge.completed) return AppColors.success;
    switch (challenge.type) {
      case 'hydration':
        return AppColors.steelColor;
      case 'nutrition':
        return const Color(0xFFFFA726);
      case 'workout':
        return const Color(0xFF29B6F6);
      case 'meditation':
        return const Color(0xFF7E57C2);
      case 'medication':
        return const Color(0xFF66BB6A);
      default:
        return AppColors.steelColor;
    }
  }

  Color _iconBgColor() => _iconColor().withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    final color = _iconColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Challenge icon ────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconBgColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconData(), color: color, size: 24),
          ),
          const SizedBox(width: 12),

          // ── Title + subtitle + progress bar ───────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: challenge.completed
                        ? AppColors.success
                        : const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),

                // Dynamic progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── XP reward badge ───────────────────────────
          Text(
            '+${challenge.xpReward} XP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: challenge.completed
                  ? AppColors.success
                  : AppColors.steelColor,
            ),
          ),
        ],
      ),
    );
  }
}
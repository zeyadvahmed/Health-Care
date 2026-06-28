import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActivityCard extends StatelessWidget {
  // Challenge display data
  final String title;
  final String subtitle;
  final String xpReward;    // e.g. "+50 XP"
  final double progress;    // 0.0 to 1.0
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isCompleted;

  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xpReward,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // ── Title + progress ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.success : iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── XP reward badge ───────────────────────────
          Text(
            xpReward,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isCompleted ? AppColors.success : AppColors.steelColor,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MedicationCard extends StatelessWidget {
  // Medication display data
  final String medicationName;
  final String dosage;
  final String frequency;
  final String reminderTime;
  final bool isTaken;

  // Action callbacks — business logic lives in cubit
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleTaken;

  const MedicationCard({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.reminderTime,
    required this.isTaken,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleTaken,
  });


  IconData _iconData() {
    final f = frequency.toLowerCase();
    if (f.contains('twice')) return Icons.medication_liquid_rounded;
    if (f.contains('every')) return Icons.timer_rounded;
    return Icons.medication_rounded;
  }


  Color _iconColor() {
    final f = frequency.toLowerCase();
    if (f.contains('twice')) return const Color(0xFFFFA726);
    if (f.contains('every')) return const Color(0xFF7E57C2);
    return AppColors.steelColor;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _iconColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Medication type icon ──────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconData(), color: accent, size: 22),
            ),
            const SizedBox(width: 12),

            // ── Name + subtitle row ───────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication name
                  Text(
                    medicationName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Dosage · time — subtitle line
                  Text(
                    '$dosage · $reminderTime',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Frequency chip
                  _frequencyChip(accent),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Actions column ────────────────────────────
            Column(
              children: [
                // Taken toggle checkbox
                GestureDetector(
                  onTap: onToggleTaken,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTaken
                          ? AppColors.steelColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isTaken
                            ? AppColors.steelColor
                            : const Color(0xFFCCCCCC),
                        width: 2,
                      ),
                    ),
                    child: isTaken
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Edit icon
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF888888),
                    size: 18,
                  ),
                ),
                const SizedBox(height: 10),

                // Delete icon
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _frequencyChip(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        frequency,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

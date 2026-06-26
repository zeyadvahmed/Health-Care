import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/hydration_entry_model.dart';

class WaterEntryCard extends StatelessWidget {
  // The hydration entry to display
  final HydrationEntryModel entry;

  // Optional callbacks — null means no action available
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  // When false, edit and delete buttons are hidden.
  // Useful for read-only contexts like dashboards.
  final bool showActions;

  const WaterEntryCard({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
  });

  String _formattedTime() {
    final t = entry.timestamp;
    final hour = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _syncIcon() =>
      entry.isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded;

  Color _syncColor() =>
      entry.isSynced ? AppColors.success : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Water icon ────────────────────────────
              _WaterIcon(amountMl: entry.amountMl),
              const SizedBox(width: 12),

              // ── Main content ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount row + sync indicator
                    Row(
                      children: [
                        Text(
                          '${entry.amountMl} ml',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sync status icon
                        Icon(
                          _syncIcon(),
                          size: 14,
                          color: _syncColor(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Time + type subtitle
                    Text(
                      '${_formattedTime()}  ·  ${entry.type}',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF888888),
                      ),
                    ),


                  ],
                ),
              ),

              // ── Action buttons ────────────────────────
              if (showActions) ...[
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF888888),
                  onTap: onEdit,
                ),
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterIcon extends StatelessWidget {
  final int amountMl;

  const _WaterIcon({required this.amountMl});

  // Scales icon background opacity based on intake amount
  Color get _bgColor {
    if (amountMl >= 500) return const Color(0xFF89C2FE).withOpacity(0.30);
    if (amountMl >= 250) return const Color(0xFF89C2FE).withOpacity(0.18);
    return const Color(0xFF89C2FE).withOpacity(0.10);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        color: AppColors.hydrationRing,
        size: 22,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}
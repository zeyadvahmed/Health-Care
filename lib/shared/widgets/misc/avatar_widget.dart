// ============================================================
// avatar_widget.dart
// lib/shared/widgets/misc/avatar_widget.dart
//
// PURPOSE:
//   User avatar showing profile image or initials fallback.
//   Optionally shows a level badge on the bottom right corner.
//
// USED IN:
//   home_screen       — top right corner
//   profile_screen    — header
//   activity_screen   — leaderboard rows
//
// INITIALS LOGIC:
//   Split name by spaces, take first letter of each word, max 2.
//   "Zeyad Ahmed" → "ZA"
//   "Basmala"     → "B"
//
// PARAMETERS:
//   name       — full name for initials fallback (required)
//   imageUrl   — profile image URL, shown if not null
//   radius     — circle radius, defaults to 24
//   onTap      — optional tap callback
//   levelBadge — optional level number shown as badge
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final int? levelBadge;

  const AvatarWidget({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.onTap,
    this.levelBadge,
  });

  // ----------------------------------------------------------
  // _initials()
  // Splits the name by spaces, takes the first letter of each
  // word, joins up to 2 letters, uppercased.
  // "Zeyad Ahmed" → "ZA"
  // "Basmala"     → "B"
  // ----------------------------------------------------------
  String _initials() {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Build the base avatar circle
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.steelColor,
      // If imageUrl exists show network image,
      // otherwise show initials text
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              _initials(),
              style: TextStyle(
                fontSize: radius * 0.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : null,
    );

    // Wrap with level badge if provided
    Widget result = levelBadge != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              // Badge positioned at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.steelColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$levelBadge',
                    style: TextStyle(
                      fontSize: radius * 0.3,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        : avatar;

    // Wrap with GestureDetector if onTap provided
    if (onTap != null) {
      result = GestureDetector(onTap: onTap, child: result);
    }

    return result;
  }
}

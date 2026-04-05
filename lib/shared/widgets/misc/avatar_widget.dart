// ============================================================
// avatar_widget.dart
// User avatar that shows profile image or falls back to initials.
//
// Usage:
//   AvatarWidget(name: 'Zezo')
//   AvatarWidget(
//     name: 'Zezo',
//     imageUrl: user.profileImageUrl,
//     radius: 36,
//     onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
//   )
//   AvatarWidget(
//     name: 'Zezo',
//     radius: 20,
//     levelBadge: 5,
//   )
//
// Parameters:
//   name       — user's full name, used to generate initials (required)
//   imageUrl   — optional profile image URL, shown if not null
//   radius     — circle radius, defaults to 24
//   onTap      — optional tap callback, wraps avatar in GestureDetector
//   levelBadge — optional level number shown as small badge on bottom right
//
// Initials logic:
//   Split name by space, take first letter of each word, max 2 letters
//   Example: "Zeyad Ahmed" → "ZA"
//
// Rules:
//   - StatelessWidget — all data passed in, no internal state
//   - If imageUrl is not null → show CircleAvatar with NetworkImage
//   - If imageUrl is null → show CircleAvatar with initials text
//   - Background color for initials avatar: AppColors.steelColor
//   - Level badge: small blue circle, white bold number, bottom right corner
// ============================================================
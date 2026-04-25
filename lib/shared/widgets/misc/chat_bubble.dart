// ============================================================
// chat_bubble.dart
// lib/shared/widgets/misc/chat_bubble.dart
//
// PURPOSE:
//   Single message bubble in the chatbot conversation.
//   User messages appear aligned right in blue.
//   Bot messages appear aligned left in light grey.
//
// USED IN:
//   chatbot_screen.dart — one ChatBubble per message
//
// PARAMETERS:
//   message   — text content of the message (required)
//   isUser    — true = right blue bubble, false = left grey bubble
//   timestamp — time shown below the bubble
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  // ----------------------------------------------------------
  // _formatTime()
  // Formats the timestamp as HH:MM for display below bubble.
  // ----------------------------------------------------------
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    // User bubble: right-aligned, steel blue background
    // Bot bubble:  left-aligned, card background (light grey)
    final bubbleColor = isUser
        ? AppColors.steelColor
        : AppColors.cardBackground;

    final textColor = isUser
        ? Colors.white
        : AppColors.textPrimary;

    // Border radius — slightly flattened on the side the tail points
    // User messages tail points bottom-right → flatten bottom-right
    // Bot messages tail points bottom-left  → flatten bottom-left
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft:     Radius.circular(18),
            topRight:    Radius.circular(18),
            bottomLeft:  Radius.circular(18),
            bottomRight: Radius.circular(4), // flattened tail side
          )
        : const BorderRadius.only(
            topLeft:     Radius.circular(4), // flattened tail side
            topRight:    Radius.circular(18),
            bottomLeft:  Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [

          // Bubble
          Container(
            constraints: BoxConstraints(
              // Max 75% of screen width — prevents full-width bubbles
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              border: isUser
                  ? null
                  : Border.all(
                      color: AppColors.divider, width: 0.8),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 3),

          // Timestamp below the bubble
          Text(
            _formatTime(timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
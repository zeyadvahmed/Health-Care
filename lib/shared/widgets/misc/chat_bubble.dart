// ============================================================
// chat_bubble.dart
// Single message bubble in the chatbot conversation.
// User messages appear on the right, bot messages on the left.
//
// Usage:
//   ChatBubble(
//     message: 'How many sets should I do?',
//     isUser: true,
//     timestamp: DateTime.now(),
//   )
//   ChatBubble(
//     message: 'For hypertrophy, 3-4 sets per exercise is ideal.',
//     isUser: false,
//     timestamp: DateTime.now(),
//   )
//
// Parameters:
//   message   — the text content of the message (required)
//   isUser    — true = user bubble on right, false = bot bubble on left (required)
//   timestamp — time the message was sent, shown below the bubble (required)
//
// Rules:
//   - StatelessWidget — displays fixed message data, no internal state
//   - User bubble color: AppColors.steelColor, white text
//   - Bot bubble color: AppColors.cardBackground, AppColors.textPrimary text
//   - Timestamp text: AppColors.textSecondary, small font
//   - Bubble has rounded corners, slightly less rounded on the side it points from
// ============================================================
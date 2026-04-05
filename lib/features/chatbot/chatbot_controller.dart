// ============================================================
// chatbot_controller.dart
// Manages the chat message list and AI API calls.
//
// Usage:
//   final controller = ChatbotController();
//   await controller.sendMessage('How many sets should I do?');
//
// State to expose:
//   bool isLoading                    — true while waiting for AI response
//   List<Map<String, dynamic>> messages — full conversation list
//                                         each map: {
//                                           'text': String,
//                                           'isUser': bool,
//                                           'timestamp': DateTime
//                                         }
//
// Methods to implement:
//   sendMessage(String text)          — add user message to list,
//                                       set isLoading true,
//                                       call AI API with message,
//                                       add AI response to list,
//                                       set isLoading false
//
// AI API:
//   Use the Anthropic API or any AI provider agreed with team lead
//   Keep system prompt fitness-focused:
//   "You are a fitness assistant for the SparkSteel app.
//    Answer questions about workouts, nutrition, and health."
//
// Rules:
//   - Always add user message to list before making the API call
//   - Always set isLoading false in finally block
//   - On API error add a fallback bot message: "Sorry, I couldn't reach the server."
//   - No Flutter UI imports except material.dart if needed
// ============================================================
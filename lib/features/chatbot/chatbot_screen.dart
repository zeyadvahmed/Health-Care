// ============================================================
// chatbot_screen.dart
// AI fitness assistant chat screen.
//
// What to build:
//   - CustomAppBar title: 'Chat Bot' with back button
//   - Scrollable ListView of ChatBubble widgets
//     auto-scrolls to bottom on new message
//   - LoadingWidget or typing indicator while chatbotController.isLoading is true
//   - Bottom row: CustomTextField for message input + circular send button
//     send button → chatbotController.sendMessage(text) → clear input field
//
// Controller usage:
//   - chatbotController.messages list drives the ListView
//   - Rebuild list on every new message
//
// Rules:
//   - StatefulWidget — message list grows, loading state changes
//   - Use ScrollController to auto-scroll to bottom after each new message
//   - Clear input field immediately after sending
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chatbot Screen')),
    );
  }
}
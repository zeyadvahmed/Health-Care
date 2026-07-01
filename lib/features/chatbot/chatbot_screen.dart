// // ============================================================
// // chatbot_screen.dart
// // AI fitness assistant chat screen.
// //
// // Reads messages from Firestore under:
// //   User/{user_id}/conversations/{conversation_id}/messages/{message_id}
// // ============================================================

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sparksteel/core/constants/app_colors.dart';
// import 'package:sparksteel/core/constants/app_strings.dart';
// import 'package:sparksteel/shared/widgets/misc/chat_bubble.dart';

// class ChatbotScreen extends StatefulWidget {
//   const ChatbotScreen({super.key});

//   @override
//   State<ChatbotScreen> createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   // late final ChatbotController _chatController;
//   bool _isLoading = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null || uid.isEmpty) {
//       _error = 'Please sign in to load your chat messages.';
//     } else {
//       _chatController = ChatbotController(uid: uid);
//     }
//   }

//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty || _error != null) return;

//     setState(() {
//       _isLoading = true;
//       _messageController.clear();
//     });

//     try {
//       await _chatController.sendUserMessage(text);
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to send message. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(AppStrings.chatBot),
//         backgroundColor: AppColors.steelColor,
//       ),
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: _error != null
//                   ? Center(
//                       child: Text(
//                         _error!,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: AppColors.textHint,
//                           fontSize: 16,
//                         ),
//                       ),
//                     )
//                   : StreamBuilder<List<ChatMessage>>(
//                       stream: _chatController.messagesStream,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         }

//                         if (snapshot.hasError) {
//                           return Center(
//                             child: Text(
//                               'Unable to load chat messages.',
//                               style: const TextStyle(color: AppColors.textHint),
//                             ),
//                           );
//                         }

//                         final messages = snapshot.data ?? [];
//                         if (messages.isEmpty) {
//                           return const Center(
//                             child: Text(
//                               'Send a message to start your chat conversation.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: AppColors.textHint,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           );
//                         }

//                         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//                         return ListView.builder(
//                           controller: _scrollController,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           itemCount: messages.length,
//                           itemBuilder: (context, index) {
//                             final message = messages[index];
//                             return ChatBubble(
//                               message: message.text,
//                               isUser: message.isUser,
//                               timestamp: message.timestamp,
//                             );
//                           },
//                         );
//                       },
//                     ),
//             ),
//             if (_isLoading)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8),
//                 child: Text(
//                   'Typing...',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textHint,
//                   ),
//                 ),
//               ),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 10,
//               ),
//               color: AppColors.cardBackground,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: (_) => _sendMessage(),
//                       decoration: InputDecoration(
//                         hintText: AppStrings.messageHint,
//                         filled: true,
//                         fillColor: AppColors.inputFill,
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(28),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     height: 52,
//                     width: 52,
//                     decoration: const BoxDecoration(
//                       color: AppColors.chatColor,
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       onPressed: _sendMessage,
//                       icon: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

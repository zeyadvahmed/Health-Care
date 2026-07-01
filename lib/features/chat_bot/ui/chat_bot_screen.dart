
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
import 'package:sparksteel/features/chat_bot/logic/chat_bot_logic.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/chat_history_drawer.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/message_bubble_widget.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/send_message_widget.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/typing_indicator_widget.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final logic = ChatBotLogic();
    logic.resetForCurrentUser();
    if (logic.currentConversationId.value == null) {
      logic.createNewConversation();
    }
  }

  int _timestampValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final logic = ChatBotLogic();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chat bot'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: Icon(
              Icons.history,
              color: Colors.grey[800],
              size: 24,
            ),
          ),
        ],
      ),
      endDrawer: const ChatHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: logic.currentConversationId,
              builder: (context, conversationId, _) {
                if (conversationId == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: logic.getMessages(conversationId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No messages'));
                    }

                    final messages = snapshot.data!.docs
                        .map((doc) => doc.data())
                        .toList();

                    messages.sort((a, b) {
                      final aTimestamp = _timestampValue(a['timestamp']);
                      final bTimestamp = _timestampValue(b['timestamp']);
                      return aTimestamp.compareTo(bTimestamp);
                    });

                    final isWaiting = messages.isNotEmpty &&
                        messages.last['sender']?.toString() == 'user';

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length + (isWaiting ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isWaiting && index == messages.length) {
                          return const TypingIndicatorWidget();
                        }
                        final message = messages[index];
                        return MessageBubbleWidget(
                          text: message['text']?.toString() ?? '',
                          sender: message['sender']?.toString() ?? 'bot',
                          timestamp: _timestampValue(message['timestamp']),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SendMessageWidget(),
        ],
      ),
    );
  }
}

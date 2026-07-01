
import 'package:flutter/material.dart';
import 'package:sparksteel/features/chat_bot/logic/chat_bot_logic.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;

    if (isToday) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final logic = ChatBotLogic();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chat history',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: () async {
                      await logic.createNewConversation();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: logic.getConversations(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final conversations = snapshot.data!;
                  if (conversations.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No conversations yet.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  return ValueListenableBuilder<String?>(
                    valueListenable: logic.currentConversationId,
                    builder: (context, currentId, _) {
                      return ListView.separated(
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          final id = conv['id'] as String;
                          final isSelected = id == currentId;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue.withValues(
                              alpha: 0.08,
                            ),
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color:
                                  isSelected
                                      ? Colors.blue
                                      : Colors.grey[600],
                            ),
                            title: Text(
                              conv['preview'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              _formatTime(conv['lastTimestamp'] as int),
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () {
                              logic.selectConversation(id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

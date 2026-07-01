import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatBotLogic {
  ChatBotLogic._();
  static final ChatBotLogic _instance = ChatBotLogic._();
  factory ChatBotLogic() => _instance;

  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  final ValueNotifier<String?> currentConversationId =
      ValueNotifier<String?>(null);

  String? _lastUserId;

  void resetForCurrentUser() {
    final uid = userId;
    if (_lastUserId != uid) {
      _lastUserId = uid;
      currentConversationId.value = null;
      textController.clear();
    }
  }

  CollectionReference<Map<String, dynamic>> get _conversationsCollection =>
      _firestore.collection('User').doc(userId).collection('conversations');

  Future<String> createNewConversation() async {
    const conversationId = 'default';
    final conversationRef = _conversationsCollection.doc(conversationId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await conversationRef.set({
      'createdAt': timestamp,
      'preview': 'New chat',
      'lastTimestamp': timestamp,
    }, SetOptions(merge: true));

    currentConversationId.value = conversationId;
    return conversationId;
  }

  void selectConversation(String id) {
    currentConversationId.value = id;
  }

  Stream<List<Map<String, dynamic>>> getConversations() {
    return _conversationsCollection.snapshots().map((snapshot) {
      final conversations = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'preview': data['preview']?.toString() ?? 'New chat',
          'lastTimestamp': (data['lastTimestamp'] as num?)?.toInt() ??
              (data['createdAt'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();

      conversations.sort(
        (a, b) =>
            (b['lastTimestamp'] as int).compareTo(a['lastTimestamp'] as int),
      );

      return conversations;
    });
  }

  Future<void> sendMessage() async {
    final convId = currentConversationId.value;
    if (convId == null) return;

    final text = textController.text.trim();
    if (text.isEmpty) return;

    final messagesRef = _conversationsCollection
        .doc(convId)
        .collection('messages');

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await messagesRef.add({
      'sender': 'user',
      'text': text,
      'timestamp': timestamp,
    });

    await _conversationsCollection.doc(convId).set({
      'preview': text,
      'lastTimestamp': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String conversationId) {
    return _conversationsCollection
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}


import 'package:flutter/material.dart';
import 'package:sparksteel/features/chat_bot/logic/chat_bot_logic.dart';

class TypeMessageWidget extends StatelessWidget {
  const TypeMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ChatBotLogic().formKey,
      child: TextFormField(
        controller: ChatBotLogic().textController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Write message first';
          }
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          hintText: 'Type a message ...',
          hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: const Color(0x00000000)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: const Color(0x00000000)),
          ),
        ),
        style: TextStyle(color: Colors.grey[800]),
      ),
    );
  }
}

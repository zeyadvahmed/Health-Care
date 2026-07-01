
import 'package:flutter/material.dart';
import 'package:sparksteel/features/chat_bot/logic/chat_bot_logic.dart';

class SendBtnWidget extends StatelessWidget {
  const SendBtnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{
        if (ChatBotLogic().formKey.currentState!.validate()) {
          await ChatBotLogic().sendMessage();
          ChatBotLogic().textController.clear();
        }
      },
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            Icons.send,
            color: Colors.white,
          )
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/send_btn_widget.dart';
import 'package:sparksteel/features/chat_bot/ui/widgets/type_message_widget.dart';

class SendMessageWidget extends StatelessWidget {
  const SendMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: TypeMessageWidget(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.scale(scale: 0.9, child: SendBtnWidget()),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MoodBtn extends StatelessWidget {
  String mood;
  String emoji;
  Color color;
  MoodBtn({
    super.key,
    required this.mood,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color, // Placeholder color
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(emoji,height: 20,width: 20,fit: BoxFit.cover,),
          ), // Placeholder icon
        ),
        Text(mood, style: TextStyle(fontSize: 14, color: Color(0xff4B4B4B))),
      ],
    );
  }
}

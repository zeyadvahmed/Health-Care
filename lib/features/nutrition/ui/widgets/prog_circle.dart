import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final double percent; // مثال: 0.77
  final int value;

  const ProgressCircle({super.key, required this.percent, required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الخلفية
        CircularProgressIndicator(
          value: 1,
          strokeWidth: 40,
          color: Colors.grey.shade300,
        ),

      
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: percent),
          duration: Duration(seconds: 1),
          builder: (context, value, child) {
            return CircularProgressIndicator(
              value: value,
              strokeWidth: 40,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
              backgroundColor: Colors.grey.shade300,
              strokeCap: StrokeCap.round,
            );
          },
        ),

        // النص في النص
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${(percent * 100).toInt()}%",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class CustomProgressCircle extends StatefulWidget {
  final double percent;
  final double radius;

  const CustomProgressCircle({
    super.key,
    required this.percent,
    this.radius = 60,
  });

  @override
  State<CustomProgressCircle> createState() => _CustomProgressCircleState();
}

class _CustomProgressCircleState extends State<CustomProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = Tween<double>(
      begin: 0,
      end: widget.percent,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  void didUpdateWidget(covariant CustomProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.percent != oldWidget.percent) {
      animation = Tween<double>(
        begin: animation.value,
        end: widget.percent,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.radius * 2, widget.radius * 2),
          painter: CirclePainter(animation.value),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(4.0),
              width: widget.radius ,
              height: widget.radius ,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${(animation.value * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.steelColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CirclePainter extends CustomPainter {
  final double percent;

  CirclePainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // الخلفية
    final bgPaint = Paint()
      ..color = Color.fromARGB(161, 137, 193, 254)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    canvas.drawCircle(center, radius, bgPaint);

    // التقدم (Gradient)
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff137FEC), AppColors.steelColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * percent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

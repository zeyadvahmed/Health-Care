import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
import 'package:sparksteel/features/nutrition/ui/widgets/custom_prog.dart';

class DailyProg extends StatelessWidget {
  final String date;
  const DailyProg({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    const totalCalories = 0;
    const percent = 0.0;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Color(0xffDAEAF9),
        border: Border.all(color: Color(0xff9DC1E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff545454),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$totalCalories',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 23,
                                color: AppColors.steelColor,
                              ),
                            ),
                            Text('/ 2000 kcal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${2000 - totalCalories} kcal remaining',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xff545454),
                    ),
                  ),
                ],
              ),
            ),
            // ProgressCircle(percent: 0.77, value: 1800),
            CustomProgressCircle(percent: percent, radius: 50),
          ],
        ),
      ),
    );
  }
}

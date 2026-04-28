import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class MoodHistory extends StatelessWidget {
  const MoodHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mood History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    'Last 7 days',
                    style: TextStyle(fontSize: 14, color: AppColors.moodHappy),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(data.length, (index) {
                  final mood = data[index]["mood"];
                  final value = getMoodValue(mood);
                  // final color = getMoodColor(mood);

                  return Column(
                    children: [
                      /// البار
                      Container(
                        height: 120,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: value, // النسبة
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.steelColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(data[index]["day"]),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getMoodValue(String? mood) {
    switch (mood) {
      case "happy":
        return 1.0;
      case "calm":
        return 0.75;
      case "tired":
        return 0.5;
      case "stressed":
        return 0.25;
      default:
        return 0.0; // فاضي
    }
  }
}

final List<Map<String, dynamic>> data = [
  {"day": "Mon", "mood": "happy"},
  {"day": "Tue", "mood": "calm"},
  {"day": "Wed", "mood": "calm"},
  {"day": "Thu", "mood": "tired"},
  {"day": "Fri", "mood": "tired"},
  {"day": "Sat", "mood": "stressed"},
  {"day": "Sun", "mood": null}, // مفيش اختيار
];

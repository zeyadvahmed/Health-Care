// ============================================================
// mental_health_screen.dart
// Mood logging and mental wellness screen.
//
// What to build:
//   - CustomAppBar title: 'Mental Health'
//   - MoodSelector widget → on select calls mentalHealthController.saveMood(...)
//   - Mood history bar chart for last 7 days using mentalHealthController.lastSevenDays
//   - Daily reflection CustomTextField (multiline)
//   - Save Note CustomButton → saves note with current mood
//   - Guided exercises section with two cards:
//       '4-7-8 Breathing' and 'Deep Meditation' with play buttons
//       (play buttons can show a simple instructions dialog for now)
//   - Daily tips cards at the bottom (static content is fine)
//
// Controller usage:
//   - Call mentalHealthController.loadMoodHistory(userId) in initState
//
// Rules:
//   - StatefulWidget — mood selection, chart updates after save
//   - Background color: AppColors.background
// ============================================================

import 'package:flutter/material.dart';
import 'package:sparksteel/features/mental_health/ui/widgets/mood_btn.dart';
import 'package:sparksteel/features/mental_health/ui/widgets/mood_history.dart';
import 'package:sparksteel/features/mental_health/ui/widgets/note_widget.dart';

class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F7F8),
      appBar: AppBar(title: Text('Mental Health')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MoodBtn(
                    mood: 'Happy',
                    emoji: 'assets/images/happy 1.png',
                    color: Color.fromARGB(153, 137, 193, 254),
                  ),
                  MoodBtn(
                    mood: 'Calm',
                    emoji: 'assets/images/meditation 1.png',
                    color: Color.fromARGB(185, 173, 241, 195),
                  ),
                  MoodBtn(
                    mood: 'Tired',
                    emoji: 'assets/images/moon 1.png',
                    color: Color.fromARGB(147, 255, 217, 141),
                  ),
                  MoodBtn(
                    mood: 'Stressed',
                    emoji: 'assets/images/flash 1.png',
                    color: Color.fromARGB(186, 250, 169, 126),
                  ),
                ],
              ),
              MoodHistory(),
              Text(
                'Daily Reflection',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              NoteWidget(),
              Text(
                'Guided Exercises',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
          
            ],
          ),
        ),
      ),
    );
  }
}

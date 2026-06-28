import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/features/mental_health/logic/mental_cubit.dart';
import 'package:sparksteel/features/mental_health/logic/mental_state.dart';

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
    final cubit = context.read<MentalCubit>();
    return BlocBuilder<MentalCubit, MentalState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            cubit.changeMood(mood);
          },
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border:cubit.currentMood==mood? Border.all():null,
                  color: color, // Placeholder color
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    emoji,
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                ), // Placeholder icon
              ),
              Text(
                mood,
                style: TextStyle(fontSize: 12, color:cubit.currentMood==mood?Colors.black: Color(0xff4B4B4B)),
              ),
            ],
          ),
        );
      },
    );
  }
}

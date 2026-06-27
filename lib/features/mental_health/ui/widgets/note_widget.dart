import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
import 'package:sparksteel/features/mental_health/logic/mental_cubit.dart';
import 'package:sparksteel/data/models/mood_entry.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MentalCubit>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        spacing: 5,
        children: [
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your thoughts here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: const Color(0x002195F3)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: cubit.noteController,
          ),
          Divider(),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: TextButton(
              onPressed: () {
                cubit.addMoodSmart(
                  MoodEntry(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    mood: cubit.currentMood,
                    note: cubit.noteController.text,
                    date: DateTime.now().toString(),
                  ),
                
                );

              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.moodHappy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Save Note',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

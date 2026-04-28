import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
              focusedBorder:OutlineInputBorder(
                borderSide: BorderSide(color: const Color(0x002195F3)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                
                ),
              ) ,
              filled: true,
              fillColor: Colors.white,
            ),
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
                // Handle save note action
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
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
          )
        ],
      ),
    );
  }
}
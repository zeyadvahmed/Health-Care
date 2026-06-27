import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';
import 'package:sparksteel/data/models/guided_exercise.dart';

class GuidedItem extends StatelessWidget {
  GuidedExercise exercise;
  GuidedItem({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          spacing: 10,
          children: [
            getImage(exercise.type),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${exercise.type} . ${formatDuration(exercise.durationSeconds)} min',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final timer = ExerciseTimer();

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Column(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Timer',style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                          ),),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 186, 219, 255),
                                ),
                              ),
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              StreamBuilder<int>(
                                  stream: timer.stream,
                                  initialData: exercise.durationSeconds,
                                  builder: (context, snapshot) {
                                    return Text(formatDuration(snapshot.data!),style: TextStyle(
                                      fontSize: 27,
                                      color: Colors.black
                                    ),);
                                  },
                                )

                            ],
                          ),
                        
                        ],
                      ),
                    );
                    
                  },
                );
                timer.start(exercise.durationSeconds);
              },
              child: CircleAvatar(radius: 23, child: Icon(Icons.play_arrow)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImage(String type) {
    if (type == 'breathing') {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 206, 230, 255),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Image.asset(
            'assets/images/wind-sign 1 (1).png',
            width: 40,
            height: 40,
          ),
        ),
      );
    } else {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 195, 233, 199),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Image.asset(
            'assets/images/lotus 1.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }
  }

  
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}


class ExerciseTimer {
  final _controller = StreamController<int>();
  Timer? _timer;
  int _remaining = 0;

  // الـ Stream اللي الـ UI بيسمعه
  Stream<int> get stream => _controller.stream;

  void start(int durationSeconds) {
    stop();
    _remaining = durationSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        stop();
      } else {
        _remaining--;
        _controller.add(_remaining);
      }
    });
  }

  void pause() => _timer?.cancel();

  void resume() => start(_remaining);

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // مهم جداً — استدعيه في dispose
  void dispose() {
    stop();
    _controller.close();
  }
}
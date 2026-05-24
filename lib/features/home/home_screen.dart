import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import '../../core/constants/app_spacing.dart';

import '../../core/constants/app_text_styles.dart';

import '../../core/layouts/main_layout.dart';

import '../../shared/widgets/info_card.dart';

import '../../shared/widgets/workout_card.dart';

import '../../shared/widgets/explore_card.dart';

import '../../data/models/workout_model.dart';

import '../../data/services/workout_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final WorkoutService workoutService =
      WorkoutService();

  List<WorkoutModel> workouts = [];

  @override
  void initState() {
    super.initState();

    loadWorkouts();
  }

  Future<void> loadWorkouts() async {

    final data =
        await workoutService.getWorkouts();

    setState(() {
      workouts = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MainLayout(

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            'Welcome, Basmala',

            style:
                AppTextStyles.heading,
          ),

          const SizedBox(
            height:
                AppSpacing.small,
          ),

          const Text(
            "Let's hit your goals today!",

            style:
                AppTextStyles.subHeading,
          ),

          const SizedBox(
            height:
                AppSpacing.large,
          ),

          const InfoCard(
            title: 'Feeling Happy',

            subtitle:
                'How are you feeling today?',

            icon:
                Icons.emoji_emotions,
          ),

          const InfoCard(
            title: '1.5L / 2.5L',

            subtitle:
                'Water Intake',

            icon:
                Icons.water_drop,
          ),

          if (workouts.isNotEmpty)

            WorkoutCard(
              title:
                  workouts.last.title,

              duration:
                  workouts.last.duration,
            ),

          const Text(
            'Explore',

            style:
                AppTextStyles.heading,
          ),

          const SizedBox(
            height:
                AppSpacing.medium,
          ),

          Wrap(
            children: const [

              ExploreCard(
                title: 'Workout',

                icon:
                    Icons.fitness_center,
              ),

              ExploreCard(
                title:
                    'Medical Tracker',

                icon:
                    Icons.medical_services,
              ),

              ExploreCard(
                title:
                    'Nutrition Plan',

                icon:
                    Icons.restaurant,
              ),

              ExploreCard(
                title:
                    'Mental Health',

                icon:
                    Icons.psychology,
              ),

              ExploreCard(
                title:
                    'Hydration Tracker',

                icon:
                    Icons.local_drink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
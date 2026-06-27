import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

import '../../core/constants/app_text_styles.dart';

import '../../core/layouts/main_layout.dart';
import '../../routes/app_routes.dart';

import '../../shared/widgets/info_card.dart';

import '../../shared/widgets/cards/workout_card.dart';

import '../../shared/widgets/explore_card.dart';

import '../../data/models/workout_model.dart';

import '../../data/services/workout_service.dart';
import '../workout/workout_overview_screen.dart';

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

  void _openWorkoutOverview(WorkoutModel workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutOverviewScreen(
          workout: workout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return MainLayout(

      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: AppSpacing.large,
        ),
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

          InfoCard(
            title: 'Feeling Happy',

            subtitle:
                'How are you feeling today?',

            icon:
                Icons.emoji_emotions,

            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.mentalHealth,
            ),
          ),

          InfoCard(
            title: '1.5L / 2.5L',

            subtitle:
                'Water Intake',

            icon:
                Icons.water_drop,

            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.hydration,
            ),
          ),

          if (workouts.isNotEmpty)

            WorkoutCard(
              workout:
                  workouts.last,

              isPredefined:
                  workouts.last.isPredefined,

              onViewDetails: () => _openWorkoutOverview(workouts.last),
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
            children: [

              ExploreCard(
                title: 'Workout',

                icon:
                    Icons.fitness_center,

                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.workoutList,
                ),
              ),

              ExploreCard(
                title:
                    'Medical Tracker',

                icon:
                    Icons.medical_services,

                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.medicalTracker,
                ),
              ),

              ExploreCard(
                title:
                    'Nutrition Plan',

                icon:
                    Icons.restaurant,

                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.nutrition,
                ),
              ),

              ExploreCard(
                title:
                    'Mental Health',

                icon:
                    Icons.psychology,

                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.mentalHealth,
                ),
              ),

              ExploreCard(
                title:
                    'Hydration Tracker',

                icon:
                    Icons.local_drink,

                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.hydration,
                ),
              ),
            ],
            ),
          ],
        ),
      ),
    );
  }
}

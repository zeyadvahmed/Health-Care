import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

import '../../core/layouts/main_layout.dart';

import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

import '../../shared/widgets/custom_snackbar.dart';

import '../../data/models/workout_model.dart';

import '../../cubit/workout/workout_cubit.dart';

class EditWorkoutScreen
    extends StatelessWidget {

  final WorkoutModel workout;

  EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  late final TextEditingController
      titleController =
      TextEditingController(
    text: workout.title,
  );

  late final TextEditingController
      durationController =
      TextEditingController(
    text: workout.duration,
  );

  late final TextEditingController
      caloriesController =
      TextEditingController(
    text: workout.calories,
  );

  @override
  Widget build(BuildContext context) {

    return MainLayout(

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const SizedBox(
            height: 40,
          ),

          const Text(
            'Edit Workout',

            style:
                AppTextStyles.heading,
          ),

          const SizedBox(
            height:
                AppSpacing.large,
          ),

          CustomTextField(
            hintText:
                'Workout Title',

            controller:
                titleController,
          ),

          const SizedBox(
            height:
                AppSpacing.medium,
          ),

          CustomTextField(
            hintText:
                'Duration',

            controller:
                durationController,
          ),

          const SizedBox(
            height:
                AppSpacing.medium,
          ),

          CustomTextField(
            hintText:
                'Calories',

            controller:
                caloriesController,
          ),

          const SizedBox(
            height: 30,
          ),

          CustomButton(

            text:
                'Update Workout',

            onPressed: () async {

              if (titleController
                      .text
                      .isEmpty ||
                  durationController
                      .text
                      .isEmpty ||
                  caloriesController
                      .text
                      .isEmpty) {

                CustomSnackbar.show(
                  context,
                  'Please fill all fields',
                );

                return;
              }

              final updatedWorkout =
                  WorkoutModel(

                id: workout.id,

                title:
                    titleController.text,

                duration:
                    durationController.text,

                calories:
                    caloriesController.text,
              );

              await context
                  .read<WorkoutCubit>()
                  .updateWorkout(
                    updatedWorkout,
                  );

              CustomSnackbar.show(
                context,
                'Workout Updated',
              );

              Navigator.pop(
                context,
              );
            },
          ),
        ],
      ),
    );
  }
}
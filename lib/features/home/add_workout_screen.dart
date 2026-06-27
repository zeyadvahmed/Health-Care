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

class AddWorkoutScreen
    extends StatelessWidget {

  AddWorkoutScreen({
    super.key,
  });

  final TextEditingController
      titleController =
      TextEditingController();

  final TextEditingController
      durationController =
      TextEditingController();

  final TextEditingController
      caloriesController =
      TextEditingController();

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
            'Add Workout',

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

            text: 'Save Workout',

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

              final workout =
                  WorkoutModel(

                id:
                    DateTime.now().microsecondsSinceEpoch.toString(),

                userId:
                    '',

                name:
                    titleController.text,

                description:
                    'Calories: ${caloriesController.text}',

                durationMinutes:
                    int.tryParse(durationController.text) ?? 30,

                createdAt:
                    DateTime.now(),

                updatedAt:
                    DateTime.now(),
              );

              await context
                  .read<WorkoutCubit>()
                  .addWorkout(
                    workout,
                  );

              CustomSnackbar.show(
                context,
                'Workout Added Successfully',
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

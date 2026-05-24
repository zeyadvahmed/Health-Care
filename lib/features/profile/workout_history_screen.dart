import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

import '../../core/layouts/main_layout.dart';

import '../../data/models/workout_model.dart';

import '../../cubit/workout/workout_cubit.dart';

class WorkoutHistoryScreen
    extends StatelessWidget {

  const WorkoutHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MainLayout(

      child:
          BlocBuilder<
              WorkoutCubit,
              List<WorkoutModel>>(
        builder: (
          context,
          workouts,
        ) {

          return SingleChildScrollView(

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  children: [

                    IconButton(

                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Text(
                      'Workouts History',

                      style:
                          AppTextStyles.heading,
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                      AppSpacing.large,
                ),

                SizedBox(

                  height: 80,

                  child: ListView(

                    scrollDirection:
                        Axis.horizontal,

                    children: [

                      dayCard(
                        'Mon',
                        '12',
                        false,
                      ),

                      dayCard(
                        'Tue',
                        '13',
                        false,
                      ),

                      dayCard(
                        'Wed',
                        '14',
                        false,
                      ),

                      dayCard(
                        'Thu',
                        '15',
                        true,
                      ),

                      dayCard(
                        'Fri',
                        '16',
                        false,
                      ),

                      dayCard(
                        'Sat',
                        '17',
                        false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height:
                      AppSpacing.large,
                ),

                const Text(
                  'Recent Workouts',

                  style:
                      AppTextStyles.heading,
                ),

                const SizedBox(
                  height:
                      AppSpacing.medium,
                ),

                if (workouts.isEmpty)

                  const Center(
                    child: Padding(

                      padding:
                          EdgeInsets.only(
                        top: 50,
                      ),

                      child: Text(
                        'No Workouts Yet',
                      ),
                    ),
                  )

                else

                  ListView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        workouts.length,

                    itemBuilder:
                        (
                          context,
                          index,
                        ) {

                      final workout =
                          workouts[index];

                      return Container(

                        margin:
                            const EdgeInsets.only(
                          bottom: 20,
                        ),

                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Theme.of(
                            context,
                          ).cardColor,

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),

                          boxShadow: [

                            BoxShadow(

                              color:
                                  Colors.black
                                      .withOpacity(
                                0.05,
                              ),

                              blurRadius:
                                  10,

                              offset:
                                  const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,

                              children: [

                                Container(

                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,

                                    vertical: 6,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors.blue
                                            .withOpacity(
                                      0.1,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                      const Text(

                                    'Hard',

                                    style:
                                        TextStyle(
                                      color:
                                          Colors.blue,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Column(
                                  children: [

                                    Text(

                                      workout
                                          .duration,

                                      style:
                                          const TextStyle(

                                        fontSize:
                                            28,

                                        fontWeight:
                                            FontWeight.bold,

                                        color:
                                            Colors.blue,
                                      ),
                                    ),

                                    const Text(
                                      'DURATION',
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            Text(

                              workout.title,

                              style:
                                  const TextStyle(

                                fontSize: 28,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            const Text(
                              'Thursday, Oct 5 . 04:30 AM',

                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Row(
                              children: [

                                infoBox(
                                  Icons.fitness_center,

                                  workout.calories,

                                  'Total Volume',
                                ),

                                const SizedBox(
                                  width: 16,
                                ),

                                infoBox(
                                  Icons.directions_run,

                                  '18 Sets',

                                  'Completed',
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 24,
                            ),

                            const Text(

                              'Exercises Breakdown',

                              style: TextStyle(

                                fontSize: 20,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            const Text(

                              'Barbell Bench Press',

                              style: TextStyle(

                                fontSize: 18,

                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Wrap(

                              spacing: 10,

                              runSpacing: 10,

                              children: [

                                repChip(
                                  '12 Reps',
                                ),

                                repChip(
                                  '10 Reps',
                                ),

                                repChip(
                                  '12 Reps',
                                ),

                                repChip(
                                  '12 Reps',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dayCard(
    String day,
    String date,
    bool active,
  ) {

    return Container(

      width: 80,

      margin:
          const EdgeInsets.only(
        right: 14,
      ),

      decoration:
          BoxDecoration(

        color:
            active
                ? Colors.blue
                : Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black
                    .withOpacity(
              0.05,
            ),

            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Text(

            day,

            style: TextStyle(

              color:
                  active
                      ? Colors.white
                      : Colors.grey,

              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(

            date,

            style: TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,

              color:
                  active
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox(
    IconData icon,
    String value,
    String label,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(
          14,
        ),

        decoration:
            BoxDecoration(

          color:
              Colors.blue
                  .withOpacity(
            0.05,
          ),

          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),

        child: Row(
          children: [

            Icon(
              icon,

              color: Colors.blue,
            ),

            const SizedBox(
              width: 10,
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  value,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                Text(
                  label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget repChip(
    String text,
  ) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.blue
                .withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: Text(

        text,

        style:
            const TextStyle(
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}
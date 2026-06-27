import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/data/models/food_item.dart';
import 'package:sparksteel/features/nutrition/nutrition_cubit.dart';
import 'package:sparksteel/features/nutrition/nutrition_state.dart';
import 'package:sparksteel/shared/widgets/inputs/custom_textfield.dart';

class MealCardFood extends StatelessWidget {
  String title;
  String recommended;
  String imagePath;
  Color iconBgColor;
  MealCardFood({
    super.key,
    required this.title,
    required this.recommended,
    required this.imagePath,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final nutritionCubit = BlocProvider.of<NutritionCubit>(context);
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(219, 218, 234, 249),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                spacing: 14,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(imagePath, width: 24, height: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(recommended, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  BlocBuilder<NutritionCubit, NutritionState>(
                    builder: (context, state) {
                      double calories = 0;
                      if (title == 'Breakfast') {
                        calories = nutritionCubit.breakfastCalories;
                      } else if (title == 'Lunch') {
                        calories = nutritionCubit.lunchCalories;
                      } else if (title == 'Dinner') {
                        calories = nutritionCubit.dinnerCalories;
                      } else if (title == 'Snack') {
                        calories = nutritionCubit.snackCalories;
                      }

                      return Text(
                        calories.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: BlocBuilder<NutritionCubit, NutritionState>(
                builder: (context, state) {
                  List<FoodItem> foodItems = [];
                  if (title == 'Breakfast') {
                    foodItems = nutritionCubit.breakfast;
                  } else if (title == 'Lunch') {
                    foodItems = nutritionCubit.lunch;
                  } else if (title == 'Dinner') {
                    foodItems = nutritionCubit.dinner;
                  } else if (title == 'Snack') {
                    foodItems = nutritionCubit.snack;
                  }
                  return state is NutritionLoadingState
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          spacing: 12,
                          children: [
                            foodItems.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'No food items added yet.',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                : ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = foodItems[index];
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(item.name),
                                          Text(
                                            item.calories.toString() + ' kcal',
                                          ),
                                        ],
                                      );
                                    },
                                    itemCount: foodItems.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                  ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        spacing: 10,
                                        children: [
                                          Text(
                                            'Add Food Item',
                                            style: TextStyle(fontSize: 16),
                                          ),

                                          Form(
                                            key: nutritionCubit.formKey,
                                            child: Column(
                                              spacing: 5,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomTextfield(
                                                  label: 'Food Name',
                                                  hint: 'food name',
                                                  controller: nutritionCubit
                                                      .foodNameController,

                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Please enter a food name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                CustomTextfield(
                                                  label: 'Calories',
                                                  hint: 'Calories',
                                                  controller: nutritionCubit
                                                      .caloriesController,

                                                  keyboardType:
                                                      TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return 'Please enter calories';
                                                    }
                                                    if (double.tryParse(
                                                          value,
                                                        ) ==
                                                        null) {
                                                      return 'Please enter a valid number';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancel'),
                                                ),
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    nutritionCubit.addMeal(
                                                      DateTime.now()
                                                          .toString()
                                                          .substring(0, 10),
                                                      title,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Add'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xffDAEAF9),
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 15,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: Color(0xff137FEC)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add Food',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff137FEC),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

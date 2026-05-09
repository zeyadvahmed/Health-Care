import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/data/local/local_nutrition_service.dart';
import 'package:sparksteel/features/nutrition/model/food_item.dart';
import 'package:sparksteel/features/nutrition/nutrition_state.dart';

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit() : super(NutritionInitialState());

  double totalCalories = 0;
  getTotalcalories(String date) async {
    final calories = await LocalNutritionService().getTotalCaloriesForDate(
      date,
    );
    totalCalories = calories;
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();

  Future<void> getMealsForDateAndMeal(String date, String mealType) async {
    emit(NutritionLoadingState());
    List<FoodItem> meals = await LocalNutritionService()
        .getFoodItemsByDateAndMeal(date, mealType);
    double calories = await LocalNutritionService()
        .getTotalCaloriesForDateAndMeal(date, mealType);
    if (mealType == 'Breakfast') {
      breakfast = meals;
      breakfastCalories = calories;
    } else if (mealType == 'Lunch') {
      lunch = meals;
      lunchCalories = calories;
    } else if (mealType == 'Dinner') {
      dinner = meals;
      dinnerCalories = calories;
    } else if (mealType == 'Snack') {
      snack = meals;
      snackCalories = calories;
    }

    emit(NutritionSuccessState());

    // return meals;
  }

  double breakfastCalories = 0;
  double lunchCalories = 0;
  double dinnerCalories = 0;
  double snackCalories = 0;

  List<FoodItem> breakfast = [];
  List<FoodItem> lunch = [];
  List<FoodItem> dinner = [];
  List<FoodItem> snack = [];

  Future<void> addMeal(String date, String mealType) async {
    emit(AddNutritionLoadingState());
    if (formKey.currentState!.validate()) {
      FoodItem meal = FoodItem(
        name: foodNameController.text,
        calories: double.parse(caloriesController.text),
        mealType: mealType,
        date: date,
      );
      await LocalNutritionService().insertFoodItem(meal);
      getMealsForDateAndMeal(date, mealType);
      getTotalcalories(date);
      // if (mealType == 'Breakfast') {
      //   breakfast = meals;
      // } else if (mealType == 'Lunch') {
      //   lunch = meals;
      // } else if (mealType == 'Dinner') {
      //   dinner = meals;
      // } else if (mealType == 'Snack') {
      //   snack = meals;
      // }
      emit(AddNutritionSuccessState());
      foodNameController.clear();
      caloriesController.clear();
    }
  }
}

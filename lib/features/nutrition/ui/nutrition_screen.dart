import 'package:flutter/material.dart';
import 'package:sparksteel/core/utils/validators.dart';
import 'package:sparksteel/features/nutrition/ui/widgets/daily_prog.dart';
import 'package:sparksteel/features/nutrition/ui/widgets/meal_card.dart';
import 'package:sparksteel/shared/widgets/buttons/custom_button.dart';
import 'package:sparksteel/shared/widgets/inputs/custom_textfield.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String date = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F7F8),
      appBar: AppBar(title: Text('Nutrition Plan')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 14,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DailyProg(date: date),
              Text(
                'Today\'s Meals',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              MealCard(
                title: 'Breakfast',
                recommended: 'Recommended: 400-600 kcal',
                calories: '0 kcal',
                foodItems: [],
                onAddFood: () => addMeal(context, 'Breakfast'),
                imagePath: 'assets/images/sun 1.png',
                iconBgColor: Color(0xffFFECC6),
              ),
              MealCard(
                title: 'Lunch',
                recommended: 'Recommended: 500 kcal',
                calories: '0 kcal',
                foodItems: [],
                onAddFood: () => addMeal(context, 'Lunch'),
                imagePath: 'assets/images/lunch 1.png',
                iconBgColor: Color(0xffADF1C2),
              ),
              MealCard(
                title: 'Dinner',
                recommended: 'Recommended: 500 kcal',
                calories: '0 kcal',
                foodItems: [],
                onAddFood: () => addMeal(context, 'Dinner'),
                imagePath: 'assets/images/night-mode 1.png',
                iconBgColor: Color(0xffEDDAFF),
              ),
              MealCard(
                title: 'Snacks',
                recommended: 'Recommended: 500 kcal',
                calories: '0 kcal',
                foodItems: [],
                onAddFood: () => addMeal(context, 'Snacks'),
                imagePath: 'assets/images/cookie 1.png',
                iconBgColor: Color(0xffEDDAFF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addMeal(BuildContext context, String mealType) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Color(0xffF6F7F8),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: SizedBox(
            height: 350,
            width: double.infinity,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    'Add $mealType Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  CustomTextfield(
                    label: 'Food Name',
                    hint: 'e.g. Grilled Chicken',
                    controller: nameController,
                    validator: Validators.validateFoodName,
                  ),
                  CustomTextfield(
                    label: 'Calories',
                    hint: 'e.g. 200',
                    controller: caloriesController,
                    validator: Validators.validateCalories,
                    keyboardType: TextInputType.number,
                  ),
                  Spacer(),
                  CustomButton(
                    label: 'Save',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

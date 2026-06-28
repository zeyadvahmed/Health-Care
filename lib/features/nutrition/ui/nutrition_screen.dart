import 'package:flutter/material.dart';
import 'package:sparksteel/features/nutrition/ui/widgets/daily_prog.dart';
import 'package:sparksteel/features/nutrition/ui/widgets/meal_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              DailyProg(date: DateTime.now().toString().substring(0, 10)),
              Text('Today\'s Nutrition'),
              MealCardFood(
                title: 'Breakfast',
                recommended: '250g Oats',
                
                imagePath: 'assets/images/sun 1.png',
                iconBgColor: const Color.fromARGB(255, 252, 225, 195),
              ),
              MealCardFood(
                title: 'Lunch',
                recommended: '150g Chicken',
                imagePath: 'assets/images/lunch 1.png',
                iconBgColor: const Color.fromARGB(255, 172, 255, 188),
              ),
              MealCardFood(
                title: 'Dinner',
                recommended: '150g Chicken',
                imagePath: 'assets/images/night-mode 1.png',
                iconBgColor: const Color.fromARGB(255, 230, 204, 255),
              ),
              MealCardFood(
                title: 'Snack',
                recommended: '150g Chicken',
                imagePath: 'assets/images/cookie 1.png',
                iconBgColor: const Color.fromARGB(255, 255, 203, 237),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

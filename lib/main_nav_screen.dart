import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/home/add_workout_screen.dart';

import 'features/profile/profile_screen.dart';

import 'shared/widgets/bottom_nav_bar.dart';

class MainNavScreen
    extends StatefulWidget {

  const MainNavScreen({
    super.key,
  });

  @override
  State<MainNavScreen>
      createState() =>
          _MainNavScreenState();
}

class _MainNavScreenState
    extends State<MainNavScreen> {

  int currentIndex = 0;

  final List<Widget> screens = [

    const HomeScreen(),

    AddWorkoutScreen(),

    const Center(
      child: Text(
        'Progress Screen',
      ),
    ),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:
          screens[currentIndex],

      bottomNavigationBar:
          BottomNavBar(

        currentIndex:
            currentIndex,

        onTap: (index) {

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparksteel/features/workout/workout_controller.dart';

import 'core/constants/app_colors.dart';
import 'features/activity/cubit/activity_cubit.dart';
import 'features/activity/ui/activity_screen.dart';
import 'features/home/home_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/profile/profile_screen.dart';
import 'routes/app_routes.dart';
import 'shared/widgets/bottom_nav_bar.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    BlocProvider(
      create: (_) => WorkoutController(),
      child: const HomeScreen(),
    ),
    BlocProvider(
      create: (_) => ActivityCubit(),
      child: const ActivityScreen(
        userId: '',
        uid: '',
        userName: '',
      ),
    ),

    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.steelColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.chatbot);
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

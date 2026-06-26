import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {

  // LIGHT THEME
  static ThemeData lightTheme =
      ThemeData(

    brightness:
        Brightness.light,

    scaffoldBackgroundColor:
        AppColors.background,

    primaryColor:
        AppColors.primary,

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          AppColors.primary,

      foregroundColor:
          Colors.white,

      elevation: 0,

      centerTitle: true,
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style:
          ElevatedButton.styleFrom(

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        minimumSize:
            const Size(
          double.infinity,
          55,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(

      filled: true,

      fillColor:
          AppColors.card,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        borderSide:
            BorderSide.none,
      ),
    ),
  );

  // DARK THEME
  static ThemeData darkTheme =
      ThemeData(

    brightness:
        Brightness.dark,

    scaffoldBackgroundColor:
        AppColors.darkBackground,

    primaryColor:
        AppColors.primary,

    cardColor:
        AppColors.darkCard,

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          Colors.black,

      foregroundColor:
          Colors.white,

      elevation: 0,

      centerTitle: true,
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style:
          ElevatedButton.styleFrom(

        backgroundColor:
            AppColors.primary,

        foregroundColor:
            Colors.white,

        minimumSize:
            const Size(
          double.infinity,
          55,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(

      filled: true,

      fillColor:
          AppColors.darkCard,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        borderSide:
            BorderSide.none,
      ),
    ),
  );
}
// ============================================================
// app_theme.dart
// Complete visual theme for SparkSteel.
//
// Usage:
//   theme: AppTheme.lightTheme   (in app.dart)
//   darkTheme: AppTheme.darkTheme
//
// Rules:
//   - Never style buttons/inputs/cards manually in widgets
//   - Always let the theme handle default styling
//   - Use AppColors for all color values
// ============================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {

  // ── Light Theme ────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(

    // Tells Flutter to use Material Design 3.
    // Required for modern widget styles (chips, buttons, etc.)
    useMaterial3: true,

    // ── Color Scheme ─────────────────────────────────────────
    // The base palette Flutter uses internally across all widgets.
    // When a widget needs "the primary color" it reads from here.
    colorScheme: const ColorScheme.light(
      // Main brand color — used by active chips, progress indicators
      primary:     AppColors.steelColor,
      // Secondary brand color — used for secondary actions
      secondary:   AppColors.splashBackground,
      // Background of cards and surfaces
      surface:     AppColors.cardBackground,
      // Color used for errors inside Flutter's built-in widgets
      error:       AppColors.error,
      // Text/icon color ON TOP of primary color
      onPrimary:   AppColors.textWhite,
      // Text/icon color ON TOP of secondary color
      onSecondary: AppColors.textWhite,
      // Text/icon color ON TOP of surface/card
      onSurface:   AppColors.textPrimary,
      // Text/icon color ON TOP of error color
      onError:     AppColors.textWhite,
    ),

    // ── Scaffold Background ───────────────────────────────────
    // Default background color of every Scaffold in the app.
    // Team never needs to set backgroundColor on any screen.
    scaffoldBackgroundColor: AppColors.cardBackground,

    // ── AppBar ────────────────────────────────────────────────
    // Default style for every AppBar across all screens.
    // Team just writes AppBar(title: Text('x')) and it looks correct.
    appBarTheme: const AppBarTheme(
      // White background for all app bars
      backgroundColor: AppColors.cardBackground,
      // Color of back button and action icons
      foregroundColor: AppColors.textPrimary,
      // No shadow under the app bar
      elevation:       0,
      // Title is always centered
      centerTitle:     true,
      // Bold dark title text
      titleTextStyle: TextStyle(
        color:      AppColors.textPrimary,
        fontSize:   18,
        fontWeight: FontWeight.bold,
      ),
      // Back arrow and icon colors
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size:  24,
      ),
    ),

    // ── Text Theme ────────────────────────────────────────────
    // Defines every text size and weight in the app.
    // Team uses Theme.of(context).textTheme.bodyLarge
    // or just lets Text widgets inherit automatically.
    textTheme: const TextTheme(

      // Large screen titles — "Workouts", "Progress", "Activity"
      headlineLarge: TextStyle(
        fontSize:   28,
        fontWeight: FontWeight.bold,
        color:      AppColors.textPrimary,
      ),

      // Card and section titles — "Full Body Blast", "Daily Challenges"
      headlineMedium: TextStyle(
        fontSize:   22,
        fontWeight: FontWeight.bold,
        color:      AppColors.textPrimary,
      ),

      // Smaller section headers — "My Workouts", "Recent Workouts"
      headlineSmall: TextStyle(
        fontSize:   18,
        fontWeight: FontWeight.bold,
        color:      AppColors.textPrimary,
      ),

      // Normal readable body text — descriptions, content
      bodyLarge: TextStyle(
        fontSize:   16,
        fontWeight: FontWeight.normal,
        color:      AppColors.textPrimary,
      ),

      // Subtitles and secondary info — "Chest, Triceps", "08:00 AM"
      bodyMedium: TextStyle(
        fontSize:   14,
        fontWeight: FontWeight.normal,
        color:      AppColors.textHint,
      ),

      // Small captions — timestamps, badges, footnotes
      bodySmall: TextStyle(
        fontSize:   12,
        fontWeight: FontWeight.normal,
        color:      AppColors.textHint,
      ),

      // Text inside buttons — "Login", "Save Workout", "Start"
      labelLarge: TextStyle(
        fontSize:   16,
        fontWeight: FontWeight.bold,
        color:      AppColors.textWhite,
      ),
    ),

    // ── Elevated Button ───────────────────────────────────────
    // Default style for every ElevatedButton in the app.
    // Covers: Login, Save Workout, Start Workout, Save Exercise,
    //         Save Note, Save Medication, Collect & Continue, etc.
    // Team writes ElevatedButton(onPressed:.., child: Text(..))
    // and it automatically looks correct — no manual styling needed.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Blue background on all primary buttons
        backgroundColor: AppColors.buttonColor,
        // White text on all primary buttons
        foregroundColor: AppColors.textWhite,
        // Full width, fixed height — matches Figma
        minimumSize:     const Size(double.infinity, 56),
        // Rounded corners — matches Figma
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // Bold button text
        textStyle: const TextStyle(
          fontSize:   16,
          fontWeight: FontWeight.bold,
        ),
        // No shadow under buttons
        elevation: 0,
      ),
    ),

    // ── Text Button ───────────────────────────────────────────
    // Default style for text-only buttons with no background.
    // Covers: "Forgot Password?", "Sign Up", "Log In", "View All"
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // Blue text color matching brand
        foregroundColor: AppColors.steelColor,
        textStyle: const TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // ── Outlined Button ───────────────────────────────────────
    // Default style for buttons with a border and no fill.
    // Covers: "View Details", "Edit" buttons in workout screens
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        // Blue text matching brand
        foregroundColor: AppColors.steelColor,
        // Blue border matching brand
        side: const BorderSide(
          color: AppColors.steelColor,
          width: 1.5,
        ),
        // Smaller height than elevated buttons
        minimumSize: const Size(0, 48),
        // Rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // ── Input Decoration ──────────────────────────────────────
    // Default style for every TextFormField in the app.
    // Covers: Email, Password, Name, Exercise Name, Food Name,
    //         Medication Name, Daily Reflection, etc.
    // Team just creates TextFormField(decoration: InputDecoration(
    //   hintText: '...')) and it looks correct automatically.
    inputDecorationTheme: InputDecorationTheme(
      // Give field a background color
      filled:    true,
      // Light grey background — matches Figma
      fillColor: AppColors.inputFill,
      // Grey placeholder text style
      hintStyle: const TextStyle(
        color:    AppColors.textHint,
        fontSize: 14,
      ),
      // Internal padding — text doesn't touch the edges
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical:   18,
      ),
      // Default state — no visible border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:   BorderSide.none,
      ),
      // When field is enabled but not focused — no border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:   BorderSide.none,
      ),
      // When user taps the field — blue border appears
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.steelColor,
          width: 1.5,
        ),
      ),
      // When validation fails — red border appears
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      // When focused AND has error — red border stays
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      // Icon inside field on the left — grey color
      prefixIconColor: AppColors.textHint,
      // Icon inside field on the right (e.g. eye icon) — grey color
      suffixIconColor: AppColors.textHint,
    ),

    // ── Card Theme ────────────────────────────────────────────
    // Default style for every Card widget in the app.
    // Covers: workout cards, medication cards, challenge cards,
    //         stat cards, progress cards, etc.
    cardTheme: CardThemeData(
      // White background
      color:       AppColors.cardBackground,
      // Subtle shadow
      elevation:   2,
      // Very light shadow color
      shadowColor: AppColors.border,
      // Rounded corners — matches Figma
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Small vertical gap between cards in a list
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    // ── Bottom Navigation Bar ─────────────────────────────────
    // The 4-tab bar at the bottom: Home, Progress, Activity, Profile
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      // White background bar
      backgroundColor:      AppColors.cardBackground,
      // Active tab icon and label — blue
      selectedItemColor:    AppColors.steelColor,
      // Inactive tab icon and label — grey
      unselectedItemColor:  AppColors.textHint,
      // Active tab label style
      selectedLabelStyle:   TextStyle(
        fontSize:   11,
        fontWeight: FontWeight.bold,
      ),
      // Inactive tab label style
      unselectedLabelStyle: TextStyle(fontSize: 11),
      // Always show labels under icons
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      // Shadow above the bar
      elevation:            8,
      // All tabs same width — no shifting animation
      type: BottomNavigationBarType.fixed,
    ),

    // ── Chip Theme ────────────────────────────────────────────
    // Default style for all Chip widgets.
    // Covers: difficulty badges (BEGINNER/INTERMEDIATE/HARD),
    //         rest time chips (30s/60s/90s/120s),
    //         frequency chips (Once daily/Twice daily)
    chipTheme: ChipThemeData(
      // Light grey background when not selected
      backgroundColor: AppColors.inputFill,
      // Blue background when selected — e.g. "60s" chip selected
      selectedColor:   AppColors.steelColor,
      // Text style inside chips
      labelStyle: const TextStyle(
        fontSize:   12,
        fontWeight: FontWeight.w600,
        color:      AppColors.textPrimary,
      ),
      // Subtle grey border on all chips
      side: const BorderSide(color: AppColors.border),
      // Pill shape — matches Figma
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      // Internal horizontal and vertical padding
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Checkbox Theme ────────────────────────────────────────
    // Default style for all Checkbox widgets.
    // Covers: set completion checkboxes in active workout session,
    //         medication taken checkboxes in medical tracker
    checkboxTheme: CheckboxThemeData(
      // Green when checked, white when unchecked
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.setDone;
        return AppColors.cardBackground;
      }),
      // White tick inside the checkbox
      checkColor: WidgetStateProperty.all(AppColors.textWhite),
      // Slightly rounded checkbox corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      // Grey border when unchecked
      side: const BorderSide(
        color: AppColors.border,
        width: 1.5,
      ),
    ),

    // ── Divider Theme ─────────────────────────────────────────
    // Default style for Divider widgets between list items.
    // Covers: medication list, leaderboard list, history list
    dividerTheme: const DividerThemeData(
      // Light grey line
      color:     AppColors.divider,
      // 1 pixel thin
      thickness: 1,
      // No extra spacing around divider
      space:     1,
    ),

    // ── Icon Theme ────────────────────────────────────────────
    // Default color and size for all Icon widgets.
    // Individual icons can still override this locally.
    iconTheme: const IconThemeData(
      // Grey icons by default
      color: AppColors.textHint,
      size:  24,
    ),

  );

  // ── Dark Theme ─────────────────────────────────────────────
  // Same structure as light theme.
  // Only difference: backgrounds are dark, text is white.
  // Activated when user toggles dark mode in Profile screen.
  static ThemeData get darkTheme => ThemeData(

    useMaterial3: true,

    // Dark backgrounds, white text
    colorScheme: const ColorScheme.dark(
      primary:     AppColors.steelColor,
      secondary:   AppColors.steelColor,
      // Dark card surface
      surface:     Color(0xFF1E1E2E),
      error:       AppColors.error,
      onPrimary:   AppColors.textWhite,
      onSecondary: AppColors.textWhite,
      onSurface:   AppColors.textWhite,
      onError:     AppColors.textWhite,
    ),

    // Dark navy as main screen background
    scaffoldBackgroundColor: AppColors.splashBackground,

    // Dark app bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1B2E),
      foregroundColor: AppColors.textWhite,
      elevation:       0,
      centerTitle:     true,
      titleTextStyle: TextStyle(
        color:      AppColors.textWhite,
        fontSize:   18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textWhite,
        size:  24,
      ),
    ),

    // All text white or muted white
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.bold,   color: AppColors.textWhite),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,   color: AppColors.textWhite),
      headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold,   color: AppColors.textWhite),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textWhite),
      bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textWhiteMuted),
      bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textWhiteMuted),
      labelLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.bold,   color: AppColors.textWhite),
    ),

    // Same button style — blue stays blue in dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: AppColors.textWhite,
        minimumSize:     const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize:   16,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.steelColor,
        textStyle: const TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.steelColor,
        side: const BorderSide(color: AppColors.steelColor, width: 1.5),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Dark input fields — dark blue fill instead of light grey
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: const Color(0xFF1E2A3A),
      hintStyle: const TextStyle(
        color:    AppColors.textWhiteMuted,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical:   18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.steelColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      prefixIconColor: AppColors.textWhiteMuted,
      suffixIconColor: AppColors.textWhiteMuted,
    ),

    // Dark cards — dark blue instead of white
    cardTheme: CardThemeData(
      color:       const Color(0xFF1E2A3A),
      elevation:   2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    // Dark bottom nav bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      Color(0xFF0D1B2E),
      selectedItemColor:    AppColors.steelColor,
      unselectedItemColor:  AppColors.textWhiteMuted,
      selectedLabelStyle:   TextStyle(
        fontSize:   11,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      elevation:            8,
      type: BottomNavigationBarType.fixed,
    ),

    // Dark chips — dark blue fill instead of light grey
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1E2A3A),
      selectedColor:   AppColors.steelColor,
      labelStyle: const TextStyle(
        fontSize:   12,
        fontWeight: FontWeight.w600,
        color:      AppColors.textWhite,
      ),
      side: const BorderSide(color: Color(0xFF2E3A4A)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // Dark checkboxes — dark fill when unchecked
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.setDone;
        return const Color(0xFF1E2A3A);
      }),
      checkColor: WidgetStateProperty.all(AppColors.textWhite),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(
        color: AppColors.textWhiteMuted,
        width: 1.5,
      ),
    ),

    // Darker divider lines
    dividerTheme: const DividerThemeData(
      color:     Color(0xFF2E3A4A),
      thickness: 1,
      space:     1,
    ),

    // White-muted icons in dark mode
    iconTheme: const IconThemeData(
      color: AppColors.textWhiteMuted,
      size:  24,
    ),

  );
}
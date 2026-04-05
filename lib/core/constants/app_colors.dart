// ============================================================
// app_colors.dart
// All color constants used across the entire SparkSteel app.
//
// Usage:
//   color: AppColors.sparkColor
//   color: AppColors.steelColor
//
// Rules:
//   - Never use raw Color(0xFF...) anywhere in the app
//   - Always use AppColors.x instead
//   - Opacity → AppColors.cardBackground.withOpacity(0.5)
// ============================================================

import 'package:flutter/material.dart';

class AppColors {

  // ── Brand ──────────────────────────────────────────────────
  static const Color sparkColor    = Color(0xFFFFFFFF); // "Spark" text color
  static const Color steelColor    = Color(0xFF137FEC); // "Steel" text + accent blue

  // ── Buttons ────────────────────────────────────────────────
  static const Color buttonColor   = steelColor;        // all primary buttons
  static const Color chatColor     = Color(0xFF116EF9); // chatbot send button

  // ── Backgrounds ────────────────────────────────────────────
  static const Color splashBackground  = Color(0xFF082644); // splash + auth top
  static const Color profileBackground = steelColor;        // profile header
  static const Color cardBackground    = Color(0xFFFCFCFC); // all white cards
  static const Color inputFill         = Color(0xFFEEEEEE); // text field background

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFF000000);   // main text on white screens
  static const Color textSecondary   = Color(0xFFFFFFFF);   // text on dark/blue backgrounds
  static const Color textHint        = Color(0xFF787878);   // placeholder text in fields
  static const Color textWhite       = Color(0xFFFFFFFF);   // white text on dark backgrounds
  static const Color textWhiteMuted  = Color(0x99FFFFFF);   // 60% white — subtitles on dark bg

  // ── Status ─────────────────────────────────────────────────
  static const Color success         = Color(0xFF4CAF50);   // completed / synced / taken
  static const Color error           = Color(0xFFE53935);   // validation errors / failed sync
  static const Color warning         = Color(0xFFFF9800);   // halfway progress / caution

  // ── Activity / XP ──────────────────────────────────────────
  static const Color xpGold          = Color(0xFFFFC228);   // XP badges + level up star
  static const Color xpBackground    = Color(0xFFFFF8E1);   // warm tint behind XP card

  // ── Workout ────────────────────────────────────────────────
  static const Color setDone         = Color(0xFF4CAF50);   // completed set checkbox
  static const Color numberSetActive = steelColor;   // current active set number


  // ── Nutrition ──────────────────────────────────────────────
  static const Color proteinColor    = Color(0xFFF3B843);   // protein macro bar
  static const Color carbColor       = Color(0xFF3CB663);   // carbs macro bar
  static const Color fatColor        = Color(0xFFE23C7F);   // fats macro bar

  // ── Hydration ──────────────────────────────────────────────
  static const Color hydrationRing   = Color(0xFF89C2FE);   // water circular ring

  // ── Mood ───────────────────────────────────────────────────
  static const Color moodHappy       = steelColor;          // happy mood icon

  // ── Dividers & Borders ─────────────────────────────────────
  static const Color divider         = Color(0xFFE0E0E0);   // line between list items
  static const Color border          = Color(0xFFBDBDBD);   // unfocused input border

  // ── Overlays ───────────────────────────────────────────────
  static const Color overlay         = Color(0x80000000);   // 50% black behind modals
  static const Color transparent     = Color(0x00000000);   // fully invisible

}
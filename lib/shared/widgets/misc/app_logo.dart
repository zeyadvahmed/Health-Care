// ============================================================
// app_logo.dart
// SparkSteel brand logo widget.
// Shows the app icon and optionally the app name beside it.
//
// Usage:
//   AppLogo()
//   AppLogo(size: 80)
//   AppLogo(size: 48, showText: false)
//
// Parameters:
//   size     — icon size in logical pixels, defaults to 64
//   showText — whether to show "SparkSteel" text beside the icon
//              defaults to true
//
// Logo text rules:
//   "Spark" — white color, bold weight
//   "Steel" — AppColors.steelColor, bold weight
//   Both words same font size, displayed inline as a RichText
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Icon is a rounded square with AppColors.sparkColor background
//     and a chart/bolt icon in white inside
//   - Used in splash_screen, login_screen, signup_screen
// ============================================================
// ============================================================
// splash_screen.dart
// First screen the app opens. Checks auth state and navigates accordingly.
//
// What to build:
//   - Centered AppLogo widget (large size)
//   - App tagline text below the logo
//   - Small loading indicator at the bottom
//
// Navigation logic:
//   - Listen to AuthService.instance.authStateChanges stream
//   - If user is logged in  → pushReplacementNamed(AppRoutes.home)
//   - If user is logged out → pushReplacementNamed(AppRoutes.login)
//
// Rules:
//   - StatefulWidget — listens to auth stream in initState
//   - Cancel stream subscription in dispose()
//   - No form, no buttons — purely display + navigation
//   - Background color: AppColors.background
// ============================================================
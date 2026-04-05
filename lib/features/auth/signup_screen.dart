// ============================================================
// signup_screen.dart
// New account registration screen.
//
// What to build:
//   - AppLogo at the top
//   - Full Name CustomTextField (validator: Validators.validateName)
//   - Email CustomTextField (validator: Validators.validateEmail)
//   - Password CustomTextField (isPassword: true,
//                               validator: Validators.validatePassword)
//   - Confirm Password CustomTextField (isPassword: true,
//                                       validator: check matches password field)
//   - CustomButton 'Create Account' → calls authController.signup(name, email, password)
//   - Row of 3 SocialButtons: Google, Facebook, Apple
//   - "Already have an account? Log In" link
//     → pushNamed(AppRoutes.login)
//
// Controller usage:
//   - Show LoadingWidget when authController.isLoading is true
//   - Show error snackbar when authController.errorMessage is not null
//
// Rules:
//   - StatefulWidget — needs Form GlobalKey, TextEditingControllers
//   - Validate form before calling controller
//   - After signup → pushReplacementNamed(AppRoutes.home) — handled by controller
//   - Background color: AppColors.background
// ============================================================
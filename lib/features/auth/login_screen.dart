// ============================================================
// login_screen.dart
// Email/password login screen with social login options.
//
// What to build:
//   - AppLogo at the top
//   - Email CustomTextField (validator: Validators.validateEmail)
//   - Password CustomTextField (isPassword: true,
//                               validator: Validators.validatePassword)
//   - Forgot password link → calls authController.sendPasswordReset(email)
//   - CustomButton 'Login' → calls authController.login(email, password)
//   - Row of 3 SocialButtons: Google, Facebook, Apple
//   - "Don't have an account? Sign Up" link
//     → pushNamed(AppRoutes.signup)
//
// Controller usage:
//   - Show LoadingWidget when authController.isLoading is true
//   - Show error snackbar when authController.errorMessage is not null
//     use Helpers.showErrorSnackBar(context, message)
//
// Rules:
//   - StatefulWidget — needs Form GlobalKey, TextEditingControllers, loading state
//   - Validate form with _formKey.currentState!.validate() before calling controller
//   - After login → pushReplacementNamed(AppRoutes.home) — handled by controller
//   - Background color: AppColors.background
// ============================================================
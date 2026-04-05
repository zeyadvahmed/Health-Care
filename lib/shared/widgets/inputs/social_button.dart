// ============================================================
// social_button.dart
// Circular icon button for OAuth login options.
// Shown in login_screen and signup_screen.
//
// Usage:
//   SocialButton(
//     type: 'google',
//     onPressed: () => authController.loginWithGoogle(),
//   )
//   SocialButton(
//     type: 'facebook',
//     onPressed: () => authController.loginWithFacebook(),
//   )
//   SocialButton(
//     type: 'apple',
//     onPressed: () => authController.loginWithApple(),
//   )
//
// Parameters:
//   type       — which platform: "google" | "facebook" | "apple" (required)
//   onPressed  — callback when tapped (required)
//
// Rules:
//   - StatelessWidget — no internal state needed
//   - Use asset images or icons for each platform logo
//   - Circle shape with border, white background
//   - All three buttons same size
// ============================================================
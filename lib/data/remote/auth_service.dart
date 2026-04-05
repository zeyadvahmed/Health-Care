// ============================================================
// auth_service.dart
// All Firebase Authentication operations for the app.
//
// Usage:
//   final user = await AuthService.instance.signInWithEmail(email, password);
//   final user = await AuthService.instance.signUpWithEmail(email, password);
//   await AuthService.instance.signOut();
//   Stream<User?> stream = AuthService.instance.authStateChanges;
//
// Methods to implement:
//   signInWithEmail(String email, String password)  — Firebase email/password login
//                                                     returns FirebaseUser on success
//   signUpWithEmail(String email, String password)  — Firebase create account
//                                                     returns FirebaseUser on success
//   signInWithGoogle()                              — Google OAuth login
//   signInWithFacebook()                            — Facebook OAuth login
//   signOut()                                       — signs out current user
//   sendPasswordReset(String email)                 — sends reset email
//   getCurrentUser()                                — returns current FirebaseUser or null
//   authStateChanges                                — Stream<User?> for auth state
//
// Rules:
//   - Used only by auth_controller — never called directly from screens
//   - All methods throw exceptions on failure — controller handles error messages
//   - No Flutter UI imports — pure Dart + Firebase Auth only
// ============================================================
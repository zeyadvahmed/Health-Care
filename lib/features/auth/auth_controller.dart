// ============================================================
// auth_controller.dart
// Business logic for all authentication flows.
// Called by login_screen, signup_screen, and splash_screen.
//
// Usage:
//   final controller = AuthController();
//   await controller.login(email, password);
//   await controller.signup(name, email, password);
//   await controller.loginWithGoogle();
//   await controller.logout();
//
// State to expose:
//   bool isLoading       — true while any auth operation is in progress
//   String? errorMessage — last error to show in the screen, null if none
//
// Methods to implement:
//   login(String email, String password)   — calls auth_service.signInWithEmail
//                                            on success: save user to SQLite,
//                                            call sync_service.syncAll(),
//                                            navigate to HomeScreen
//   signup(String name, String email,      — calls auth_service.signUpWithEmail
//          String password)                  on success: create UserModel, save to
//                                            SQLite and Firestore, navigate to HomeScreen
//   loginWithGoogle()                      — calls auth_service.signInWithGoogle
//   loginWithFacebook()                    — calls auth_service.signInWithFacebook
//   logout()                               — calls auth_service.signOut,
//                                            navigates to LoginScreen using
//                                            pushNamedAndRemoveUntil
//   checkAuthState()                       — called by splash_screen on init,
//                                            navigates based on current auth state
//
// Rules:
//   - Always set isLoading true before async call, false in finally block
//   - Always set errorMessage on catch, null on start of each method
//   - Never import any screen — use Navigator via passed BuildContext
//   - No Flutter UI imports except material.dart for BuildContext
// ============================================================
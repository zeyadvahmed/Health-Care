// ============================================================
// connectivity_service.dart
// Watches device network status and exposes it as a stream.
// Uses the connectivity_plus package.
//
// Usage:
//   ConnectivityService.instance.onConnectivityChanged.listen((isOnline) {
//     if (isOnline) syncService.syncAll();
//   });
//   final online = await ConnectivityService.instance.isOnline();
//
// Methods to implement:
//   onConnectivityChanged            — Stream<bool> emitting true=online false=offline
//                                      listened to by sync_service on app start
//   isOnline()                       — one-time async check, returns bool
//
// Rules:
//   - Singleton pattern — one instance only
//   - Uses connectivity_plus ConnectivityResult to determine status
//   - No Flutter UI imports — pure Dart + connectivity_plus only
// ============================================================
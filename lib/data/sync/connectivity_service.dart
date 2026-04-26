// ============================================================
// connectivity_service.dart
// lib/data/sync/connectivity_service.dart
//
// PURPOSE:
//   Watches device network status and exposes it as a stream.
//   sync_service listens to this stream to automatically
//   trigger syncAll() when the device comes back online.
//
// CONNECTIVITY_PLUS VERSION NOTE:
//   In connectivity_plus v4+, onConnectivityChanged emits
//   List<ConnectivityResult>, not a single ConnectivityResult.
//   isOnline() checks if any result in the list is not 'none'.
//
// USAGE IN MAIN.DART:
//   ConnectivityService.instance.onConnectivityChanged.listen(
//     (isOnline) {
//       if (isOnline && currentUid != null) {
//         SyncService.instance.syncAll(currentUid!);
//       }
//     },
//   );
//
// RULES:
//   - Singleton pattern
//   - Uses connectivity_plus package
//   - No Flutter UI imports
// ============================================================

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  ConnectivityService._internal();
  static final ConnectivityService instance =
      ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // ----------------------------------------------------------
  // _isConnected()
  // Internal helper. Takes a List<ConnectivityResult> from
  // connectivity_plus v4+ and returns true if any result is
  // not ConnectivityResult.none.
  //
  // WHY A LIST:
  //   A device can be connected via multiple interfaces at once
  //   (e.g. both wifi and ethernet). The package returns all
  //   active connections. We just need at least one to be active.
  // ----------------------------------------------------------
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  // ----------------------------------------------------------
  // onConnectivityChanged (Stream)
  // Emits true when device goes online, false when offline.
  // sync_service listens to this — when true it calls syncAll().
  //
  // The stream fires every time the network status changes.
  // Example: wifi drops → emits false. Wifi reconnects → emits true.
  // ----------------------------------------------------------
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => _isConnected(results),
    );
  }

  // ----------------------------------------------------------
  // isOnline()
  // One-time check of current connectivity status.
  // Called by sync_service.syncAll() at the start of every
  // sync attempt to avoid wasting time when offline.
  //
  // Returns true if any connection type is currently active.
  // ----------------------------------------------------------
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }
}
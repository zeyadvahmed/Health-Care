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
// HOW THE AUTO-SYNC IS WIRED:
//   ConnectivityService does NOT subscribe to its own stream.
//   The subscription lives in AuthController.login() so the
//   current user UID is always available when the stream fires.
//   AuthController calls SyncService.instance.syncAll(uid)
//   every time the stream emits true (device came online).
//
// RULES:
//   - Singleton pattern
//   - Uses connectivity_plus package
//   - No Flutter UI imports
//   - debugPrint only — never plain print()
// ============================================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // ----------------------------------------------------------
  // _isConnected()
  // Internal helper. Returns true if any result in the list
  // is not ConnectivityResult.none.
  //
  // WHY A LIST:
  //   A device can be connected via multiple interfaces at once
  //   (wifi + ethernet). The package returns all active ones.
  //   We only need at least one to be active.
  // ----------------------------------------------------------
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  // ----------------------------------------------------------
  // onConnectivityChanged (Stream<bool>)
  // Emits true when device goes online, false when offline.
  //
  // WHO LISTENS:
  //   AuthController subscribes to this stream after login.
  //   It calls SyncService.instance.syncAll(uid) on every
  //   true emission so the UID is always available.
  //   The subscription is cancelled in AuthController.logout().
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
  // ----------------------------------------------------------
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }
}

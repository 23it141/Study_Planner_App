import 'dart:async';
import 'package:flutter/foundation.dart';

class SyncService {
  static Timer? _syncTimer;

  static void startSync() {
    // Simulate background sync every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (kDebugMode) {
        print('Cloud Sync: Local data is synchronized with server (Simulated)');
      }
    });
  }

  static void stopSync() {
    _syncTimer?.cancel();
  }
}

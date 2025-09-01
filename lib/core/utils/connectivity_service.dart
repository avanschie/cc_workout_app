import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _connectivityTimer;
  static const Duration _checkInterval = Duration(seconds: 30);

  void startMonitoring() {
    // Initial check
    _checkConnectivity();

    // Periodic checks
    _connectivityTimer = Timer.periodic(_checkInterval, (_) {
      _checkConnectivity();
    });
  }

  void stopMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectivity(isConnected);
      return isConnected;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Connectivity check failed: $e');
      }
      _updateConnectivity(false);
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    await checkConnectivity();
  }

  void _updateConnectivity(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);

      if (kDebugMode) {
        debugPrint(
          'Connectivity changed: ${isConnected ? 'Connected' : 'Disconnected'}',
        );
      }
    }
  }

  void dispose() {
    stopMonitoring();
    _connectivityController.close();
  }
}

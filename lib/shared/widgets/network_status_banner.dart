import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/core/utils/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  service.startMonitoring();
  return service.connectivityStream;
});

class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);

    return connectivityAsync.when(
      loading: () => child,
      error: (error, stackTrace) => child,
      data: (isConnected) {
        if (isConnected) {
          return child;
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade600,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No internet connection. Some features may not work.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(connectivityServiceProvider).checkConnectivity();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cc_workout_app/core/config/env_config.dart';

class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Only show banner in debug mode and non-production environments
    if (!kDebugMode || !EnvConfig.isConfigured) {
      return child;
    }

    final environment = EnvConfig.environment;
    if (environment == Environment.production) {
      return child;
    }

    return Banner(
      message: EnvConfig.config.name.toUpperCase(),
      location: BannerLocation.topEnd,
      color: _getBannerColor(environment),
      child: child,
    );
  }

  Color _getBannerColor(Environment environment) {
    switch (environment) {
      case Environment.local:
        return Colors.blue;
      case Environment.staging:
        return Colors.orange;
      case Environment.production:
        return Colors.red; // Should never be shown
    }
  }
}

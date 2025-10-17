import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/core/config/env_config.dart';

/// Loading screen displayed during authentication operations
///
/// Features:
/// - Centered loading indicator with app branding
/// - Environment-specific messaging (shows auto-login indicator in local dev)
/// - Proper accessibility labels and semantic structure
/// - Material 3 design with app theme integration
/// - Prevents user interaction during auth operations
class AuthLoadingScreen extends ConsumerWidget {
  const AuthLoadingScreen({
    super.key,
    this.message,
    this.showEnvironmentInfo = true,
  });

  /// Custom loading message to display
  final String? message;

  /// Whether to show environment-specific information
  final bool showEnvironmentInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get environment-specific message
    final environmentMessage = _getEnvironmentMessage();
    final displayMessage = message ?? 'Loading...';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Branding Section
                _buildAppBranding(theme, colorScheme),

                const SizedBox(height: 48),

                // Loading Indicator
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Loading Message
                Text(
                  displayMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Environment-specific information
                if (showEnvironmentInfo && environmentMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildEnvironmentInfo(theme, colorScheme, environmentMessage),
                ],

                const SizedBox(height: 48),

                // Subtle hint text
                Text(
                  'Setting up your workout tracker...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBranding(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // App Icon/Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center,
            size: 40,
            color: colorScheme.onPrimary,
          ),
        ),

        const SizedBox(height: 16),

        // App Title
        Text(
          'Rep Max Tracker',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        Text(
          'Powerlifting Progress',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEnvironmentInfo(
    ThemeData theme,
    ColorScheme colorScheme,
    String environmentMessage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              environmentMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String? _getEnvironmentMessage() {
    try {
      final config = EnvConfig.config;
      switch (EnvConfig.environment) {
        case Environment.local:
          if (config.enableAutoSignIn) {
            return 'Auto-signing in for local development...';
          }
          return 'Local development environment';
        case Environment.staging:
          return 'Staging environment - For testing only';
        case Environment.production:
          return null; // No environment info in production
      }
    } catch (e) {
      // If config is not available, don't show environment info
      return null;
    }
  }
}

/// Specialized loading screen for initial auth state determination
class AuthInitializingScreen extends StatelessWidget {
  const AuthInitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen(
      message: 'Checking authentication...',
    );
  }
}

/// Specialized loading screen for sign in operations
class SignInLoadingScreen extends StatelessWidget {
  const SignInLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen(
      message: 'Signing you in...',
      showEnvironmentInfo: false,
    );
  }
}

/// Specialized loading screen for sign up operations
class SignUpLoadingScreen extends StatelessWidget {
  const SignUpLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen(
      message: 'Creating your account...',
      showEnvironmentInfo: false,
    );
  }
}

/// Specialized loading screen for password reset operations
class PasswordResetLoadingScreen extends StatelessWidget {
  const PasswordResetLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLoadingScreen(
      message: 'Sending reset email...',
      showEnvironmentInfo: false,
    );
  }
}

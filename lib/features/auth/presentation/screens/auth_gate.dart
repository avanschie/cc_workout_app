import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/auth_loading_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';

/// Authentication gate that handles routing based on authentication state
///
/// This is the main entry point for the app that determines whether to show
/// authentication screens or the main app content based on the current auth state.
///
/// Features:
/// - Automatic routing based on authentication state
/// - Loading states during auth initialization and operations
/// - Named route support for auth screens navigation
/// - Error state handling with retry functionality
/// - Smooth transitions between auth states
/// - Environment-specific behavior (auto-login in local dev)
/// - Proper state preservation during hot reloads
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Loading state - checking authentication
      loading: () => const AuthInitializingScreen(),

      // Authenticated user - show main app
      data: (user) {
        if (user != null) {
          return const MainNavigationShell(child: SizedBox.shrink());
        } else {
          // Not authenticated - show auth navigator
          return const AuthNavigator();
        }
      },

      // Error state - show error with retry
      error: (error, stackTrace) => AuthErrorScreen(
        error: error,
        onRetry: () {
          ref.read(authControllerProvider).refresh();
        },
      ),
    );
  }
}

/// Navigator widget that handles authentication screens routing
///
/// This widget provides a nested navigation structure for authentication flows,
/// allowing users to navigate between sign in, sign up, and forgot password screens
/// while maintaining the ability to go back to the main auth entry point.
class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          // Handle back button for nested navigation
          final navigatorState = _navigatorKey.currentState;
          if (navigatorState != null && await navigatorState.maybePop()) {
            return; // Navigation handled
          }
        }
      },
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          Widget page;

          switch (settings.name) {
            case '/':
              page = const SignInScreen();
              break;
            case '/sign-up':
              page = const SignUpScreen();
              break;
            case '/forgot-password':
              page = const ForgotPasswordScreen();
              break;
            default:
              page = const SignInScreen();
          }

          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Smooth slide transition for auth screens
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
    );
  }
}

/// Error screen shown when authentication initialization fails
///
/// Provides a user-friendly error display with retry functionality
/// and helpful information about potential causes and solutions.
class AuthErrorScreen extends ConsumerWidget {
  const AuthErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 40,
                    color: colorScheme.onErrorContainer,
                  ),
                ),

                const SizedBox(height: 24),

                // Error title
                Text(
                  'Authentication Error',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Error message
                Text(
                  _getErrorMessage(error),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Retry button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ),

                const SizedBox(height: 16),

                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Troubleshooting',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your internet connection\n'
                        '• Ensure the app is up to date\n'
                        '• Try restarting the app\n'
                        '• Contact support if the problem persists',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Unable to connect to the authentication service. '
          'Please check your internet connection and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'The request timed out. Please check your connection and try again.';
    }

    if (errorString.contains('server') || errorString.contains('service')) {
      return 'The authentication service is temporarily unavailable. '
          'Please try again in a few moments.';
    }

    if (errorString.contains('config') ||
        errorString.contains('initialization')) {
      return 'App configuration error. Please restart the app or contact support.';
    }

    return 'Something went wrong while setting up authentication. '
        'Please try again or contact support if the problem continues.';
  }
}

/// Specialized auth gate for development with additional debugging information
class AuthGateWithDebugInfo extends ConsumerWidget {
  const AuthGateWithDebugInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Stack(
      children: [
        const AuthGate(),

        // Debug overlay (only in development builds)
        if (_shouldShowDebugInfo())
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: _DebugInfoBanner(authState: authState),
          ),
      ],
    );
  }

  bool _shouldShowDebugInfo() {
    // Only show in debug builds and non-production environments
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

class _DebugInfoBanner extends StatelessWidget {
  const _DebugInfoBanner({required this.authState});

  final AsyncValue<AuthUser?> authState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String statusText;
    Color statusColor;

    if (authState.isLoading) {
      statusText = 'Loading...';
      statusColor = Colors.orange;
    } else if (authState.hasError) {
      statusText = 'Error';
      statusColor = Colors.red;
    } else if (authState.hasValue && authState.value != null) {
      statusText = 'Authenticated';
      statusColor = Colors.green;
    } else {
      statusText = 'Not authenticated';
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Auth: $statusText',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

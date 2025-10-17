import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cc_workout_app/core/navigation/app_routes.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';
import 'package:cc_workout_app/features/rep_maxes/screens/rep_maxes_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/history_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/edit_lift_screen.dart';
import 'package:cc_workout_app/shared/widgets/network_status_banner.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    refreshListenable: AuthStateListenable(ref),
    redirect: (context, state) => _handleRedirect(context, state, ref),
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoute.signIn.path,
        name: AppRoute.signIn.name,
        builder: (context, state) => const NetworkStatusBanner(
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.signUp.path,
        name: AppRoute.signUp.name,
        builder: (context, state) => const NetworkStatusBanner(
          child: SignUpScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const NetworkStatusBanner(
          child: ForgotPasswordScreen(),
        ),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            name: AppRoute.home.name,
            builder: (context, state) => const RepMaxesScreen(),
          ),
          GoRoute(
            path: AppRoute.repMaxes.path,
            name: AppRoute.repMaxes.name,
            builder: (context, state) => const RepMaxesScreen(),
          ),
          GoRoute(
            path: AppRoute.history.path,
            name: AppRoute.history.name,
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),

      // Modal routes (outside the shell)
      GoRoute(
        path: AppRoute.addLift.path,
        name: AppRoute.addLift.name,
        builder: (context, state) => const AddLiftScreen(),
      ),
      GoRoute(
        path: AppRoute.editLift.path,
        name: AppRoute.editLift.name,
        builder: (context, state) {
          final liftEntry = state.extra as LiftEntry?;

          if (liftEntry == null) {
            // Redirect to history if no lift entry provided
            return const HistoryScreen();
          }
          return EditLiftScreen(liftEntry: liftEntry);
        },
      ),
    ],
  );
});

/// Handle route redirects based on authentication state
String? _handleRedirect(BuildContext context, GoRouterState state, Ref ref) {
  final authState = ref.read(authNotifierProvider);

  return authState.when(
    data: (user) {
      final isLoggedIn = user != null;
      final currentPath = state.fullPath ?? state.uri.toString();
      final isAuthRoute = _isAuthRoute(currentPath);

      if (isLoggedIn && isAuthRoute) {
        // Redirect authenticated users away from auth screens
        return AppRoute.home.path;
      }

      if (!isLoggedIn && !isAuthRoute) {
        // Redirect unauthenticated users to sign in
        return AppRoute.signIn.path;
      }

      return null; // No redirect needed
    },
    loading: () => null, // Don't redirect while loading
    error: (_, _) => AppRoute.signIn.path, // Redirect to sign in on error
  );
}

/// Check if the current route is an authentication route
bool _isAuthRoute(String location) {
  return location.startsWith(AppRoute.signIn.path) ||
         location.startsWith(AppRoute.signUp.path) ||
         location.startsWith(AppRoute.forgotPassword.path);
}

/// Listenable class to handle auth state changes for GoRouter
class AuthStateListenable extends ChangeNotifier {
  AuthStateListenable(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Extension methods for type-safe navigation
extension GoRouterExtension on GoRouter {
  /// Navigate to a route using the AppRoute enum
  void goToRoute(AppRoute route, {Map<String, String>? pathParameters}) {
    var path = route.path;

    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }

    go(path);
  }

  /// Push a route using the AppRoute enum
  void pushRoute(AppRoute route, {Map<String, String>? pathParameters}) {
    var path = route.path;

    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }

    push(path);
  }
}
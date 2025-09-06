import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/exceptions/auth_exceptions.dart';

/// Provider for the AuthRepository - to be overridden by the providers file
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'authRepositoryProvider must be overridden with actual implementation',
  );
});

/// Provider to track if user has explicitly logged out
/// This prevents auto-login after manual logout in development
final hasUserLoggedOutProvider = StateProvider<bool>((ref) => false);

/// AsyncNotifier that manages authentication state following Andrea Bizzotto's patterns.
///
/// This notifier handles:
/// - Authentication state initialization from current session
/// - Environment-specific auto-login behavior
/// - Sign in/out operations with proper error handling
/// - Listening to auth state changes from Supabase
/// - Session persistence and recovery
///
/// The notifier uses AsyncValue&lt;AuthUser?&gt; to represent:
/// - AsyncValue.loading(): Authentication status is being determined
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.data(authUser): User is authenticated
/// - AsyncValue.error(): Authentication error occurred
class AuthNotifier extends AsyncNotifier<AuthUser?> {
  StreamSubscription<AuthUser?>? _authStateSubscription;
  late AuthRepository _repository;

  @override
  Future<AuthUser?> build() async {
    // Get repository from provider system
    _repository = ref.read(authRepositoryProvider);

    // Listen to auth state changes
    _listenToAuthStateChanges();

    // Initialize with current user if available
    final currentUser = _repository.currentUser;

    // Handle environment-specific behavior
    final hasLoggedOut = ref.read(hasUserLoggedOutProvider);
    final shouldAutoLogin =
        currentUser == null && _shouldAutoLogin() && !hasLoggedOut;

    if (shouldAutoLogin) {
      return await _performAutoLogin();
    }

    return currentUser;
  }

  /// Performs sign in with magic link (OTP).
  ///
  /// Sets loading state during the operation and handles errors appropriately.
  /// The actual sign-in completion will be handled by the auth state change listener.
  Future<void> signInWithMagicLink(String email) async {
    state = const AsyncValue.loading();

    try {
      await _repository.signInWithMagicLink(email);
      // Don't update state here - let the auth state listener handle it
      // This prevents race conditions and ensures consistency
    } on AuthException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Performs sign up with email and password.
  ///
  /// Returns the newly created user on success.
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Update state with the new user
      state = AsyncValue.data(user);
      return user;
    } on AuthException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Performs sign in with email and password.
  ///
  /// Returns the authenticated user on success.
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      // Reset the logout flag since user is now signing in
      ref.read(hasUserLoggedOutProvider.notifier).state = false;

      // Update state with the authenticated user
      state = AsyncValue.data(user);
      return user;
    } on AuthException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Sends password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      // No state change needed for password reset
    } on AuthException {
      // Don't update the main auth state for password reset errors
      // The UI should handle these errors locally
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  /// Performs sign out operation.
  ///
  /// The actual state change will be handled by the auth state change listener
  /// when it receives the auth state change event from Supabase.
  Future<void> signOut() async {
    // Mark that user explicitly logged out to prevent auto-login
    ref.read(hasUserLoggedOutProvider.notifier).state = true;

    try {
      await _repository.signOut();
      // The auth state listener will handle updating the state to null
    } on AuthException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refreshes the current authentication state.
  ///
  /// Useful for recovering from error states or manually checking auth status.
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final currentUser = _repository.currentUser;
      state = AsyncValue.data(currentUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Listens to authentication state changes from Supabase.
  ///
  /// This ensures our app state stays in sync with the actual auth state,
  /// handling cases like session expiry, external sign-outs, etc.
  void _listenToAuthStateChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _repository.authStateChanges.listen(
      (user) {
        // ALWAYS update state when auth changes - this is the source of truth
        // This prevents deadlocks where loading state blocks auth updates
        state = AsyncValue.data(user);
      },
      onError: (error, stackTrace) {
        // Handle auth state stream errors
        state = AsyncValue.error(error, stackTrace);
      },
    );

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });
  }

  /// Determines if auto-login should be attempted based on environment configuration.
  bool _shouldAutoLogin() {
    try {
      final config = EnvConfig.config;
      return config.enableAutoSignIn;
    } catch (e) {
      // If config is not available, default to no auto-login for security
      return false;
    }
  }

  /// Performs environment-specific auto-login.
  ///
  /// Uses email/password for local development to avoid needing email infrastructure.
  Future<AuthUser?> _performAutoLogin() async {
    try {
      final config = EnvConfig.config;

      // Only perform auto-login if enabled in configuration
      if (!config.enableAutoSignIn) {
        return null;
      }

      // Use email/password login for local development (more reliable)
      final user = await _repository.signInWithEmailPassword(
        email: 'john@example.com',
        password: 'password123',
      );

      return user;
    } catch (e) {
      // Auto-login failed - this is not critical, just log and continue
      // The user can still manually log in if auto-login fails
      return null;
    }
  }
}

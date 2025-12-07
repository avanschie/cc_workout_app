import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_workout_app/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';

/// Provider for the Supabase client instance.
///
/// This is typically provided at the app level during initialization.
/// The client should be configured with the appropriate environment settings.
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  throw UnimplementedError(
    'supabaseClientProvider must be overridden with a configured SupabaseClient',
  );
});

// Import and override the auth repository provider from the notifier
/// Provider for the AuthRepository implementation.
///
/// Uses SupabaseAuthRepository as the default implementation.
/// Can be easily overridden for testing with mock implementations.
final authRepositoryProviderImpl = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return SupabaseAuthRepository(supabaseClient);
});

/// Main authentication state notifier provider.
///
/// This is the primary provider for authentication state management.
/// It uses AsyncNotifier to handle the async nature of authentication
/// and provides proper loading/error states.
///
/// State represents:
/// - AsyncValue.loading(): Auth status is being determined
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.data(AuthUser): User is authenticated
/// - AsyncValue.error(): Authentication error occurred
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(() {
  final notifier = AuthNotifier();
  return notifier;
}, dependencies: [authRepositoryProviderImpl]);

/// Provider for the current authentication state.
///
/// This is a convenience provider that extracts the AsyncValue from
/// the authNotifierProvider. Most UI components should use this.
final authStateProvider = Provider<AsyncValue<AuthUser?>>((ref) {
  return ref.watch(authNotifierProvider);
}, dependencies: [authNotifierProvider]);

/// Provider that returns the current authenticated user or null.
///
/// This provider:
/// - Returns null when loading or in error state
/// - Returns the AuthUser when authenticated
/// - Returns null when not authenticated
///
/// Useful for components that only care about the user data and not
/// the loading/error states.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
}, dependencies: [authStateProvider]);

/// Provider that returns whether the user is currently authenticated.
///
/// Returns:
/// - false when loading, error, or not authenticated
/// - true when authenticated with a valid user
///
/// Useful for navigation guards and conditional rendering.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}, dependencies: [currentUserProvider]);

/// Provider that returns whether authentication is currently loading.
///
/// Useful for showing loading indicators during auth operations.
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
}, dependencies: [authStateProvider]);

/// Provider that returns the current authentication error, if any.
///
/// Returns null when there's no error. Useful for displaying
/// error messages in the UI.
final authErrorProvider = Provider<Object?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.error;
}, dependencies: [authStateProvider]);

/// Stream provider for authentication state changes.
///
/// This provides direct access to the domain-level auth state changes.
/// Most components should use authStateProvider instead, but this can
/// be useful for components that need to react to specific auth events.
final authStateStreamProvider = StreamProvider<AuthUser?>((ref) {
  final authRepository = ref.read(authRepositoryProviderImpl);
  return authRepository.authStateChanges;
});

/// Provider for auth controller/facade that exposes auth operations.
///
/// This provides a clean interface for UI components to interact with
/// auth functionality without directly accessing the notifier.
final authControllerProvider = Provider<AuthController>(
  (ref) {
    return AuthController(ref);
  },
  dependencies: [
    authNotifierProvider,
    currentUserProvider,
    isAuthenticatedProvider,
    isAuthLoadingProvider,
    authErrorProvider,
  ],
);

/// Returns provider overrides for auth providers.
/// This should be used when initializing the app to properly wire dependencies.
List<dynamic> getAuthProviderOverrides() {
  return [
    authRepositoryProvider.overrideWith((ref) {
      return ref.read(authRepositoryProviderImpl);
    }),
  ];
}

/// Controller class that provides a clean interface for auth operations.
///
/// This follows the controller pattern recommended by Andrea Bizzotto
/// for separating UI interaction logic from state management logic.
class AuthController {
  const AuthController(this._ref);

  final Ref _ref;

  /// Signs up with email and password.
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    return await notifier.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// Signs in with email and password.
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    return await notifier.signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  /// Sends password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    await notifier.sendPasswordResetEmail(email);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    await notifier.signOut();
  }

  /// Refreshes the authentication state.
  ///
  /// Useful for recovering from error states or manually checking auth status.
  Future<void> refresh() async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    await notifier.refresh();
  }

  /// Gets the current user, if authenticated.
  AuthUser? get currentUser => _ref.read(currentUserProvider);

  /// Gets whether the user is currently authenticated.
  bool get isAuthenticated => _ref.read(isAuthenticatedProvider);

  /// Gets whether authentication is currently loading.
  bool get isLoading => _ref.read(isAuthLoadingProvider);

  /// Gets the current authentication error, if any.
  Object? get error => _ref.read(authErrorProvider);
}

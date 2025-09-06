import '../entities/auth_user.dart';

/// Abstract repository for authentication operations.
/// Defines the contract for authentication data access.
abstract class AuthRepository {
  /// Returns the currently authenticated user, if any.
  AuthUser? get currentUser;

  /// Stream of authentication state changes.
  Stream<AuthUser?> get authStateChanges;

  /// Sign in with magic link (OTP via email).
  Future<void> signInWithMagicLink(String email);

  /// Sign up with email and password.
  /// Returns the created user.
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with email and password.
  /// Returns the authenticated user.
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out the current user.
  Future<void> signOut();

  /// Refresh the current user session.
  Future<AuthUser?> refreshSession();
}

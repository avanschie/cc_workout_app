import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase
    show AuthException;

import '../../../../core/config/env_config.dart';
import '../../domain/entities/auth_user.dart' as domain;
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_user_dto.dart';

/// Supabase implementation of the AuthRepository.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;
  StreamController<domain.AuthUser?>? _authStateController;
  StreamSubscription<AuthState>? _authStateSubscription;

  SupabaseAuthRepository(this._supabase) {
    _initializeAuthStateStream();
  }

  void _initializeAuthStateStream() {
    _authStateController = StreamController<domain.AuthUser?>.broadcast();

    // Check initial session on repository creation
    if (kDebugMode) {
      final initialSession = _supabase.auth.currentSession;
      debugPrint(
        'DEBUG Auth Repository: Initial session on creation: ${initialSession?.user.email}',
      );
      debugPrint(
        'DEBUG Auth Repository: Initial session token present: ${initialSession?.accessToken != null}',
      );
    }

    // Add initial user state if already logged in
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      if (kDebugMode) {
        debugPrint(
          'DEBUG Auth Repository: Found existing user on init: ${currentUser.email}',
        );
      }
      final userDto = AuthUserDto.fromSupabaseUser(currentUser);
      _authStateController?.add(userDto.toDomain());
    }

    // Listen to Supabase auth state changes and map to domain entities
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((
      authState,
    ) {
      if (kDebugMode) {
        debugPrint('DEBUG Auth Repository: Auth state changed');
        debugPrint('DEBUG Auth Repository: Event: ${authState.event}');
        debugPrint(
          'DEBUG Auth Repository: User: ${authState.session?.user.email}',
        );
        debugPrint(
          'DEBUG Auth Repository: Session present: ${authState.session != null}',
        );
      }

      final user = authState.session?.user;
      if (user != null) {
        final userDto = AuthUserDto.fromSupabaseUser(user);
        _authStateController?.add(userDto.toDomain());
      } else {
        _authStateController?.add(null);
      }
    });
  }

  @override
  domain.AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final userDto = AuthUserDto.fromSupabaseUser(user);
    return userDto.toDomain();
  }

  @override
  Stream<domain.AuthUser?> get authStateChanges {
    return _authStateController?.stream ?? const Stream.empty();
  }

  @override
  Future<void> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: true);
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownAuthException(
        'An unexpected error occurred during magic link sign in: $e',
      );
    }
  }

  @override
  Future<domain.AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Attempting sign up for email: $email');
        debugPrint('DEBUG Auth: Display name: $displayName');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (kDebugMode) {
        debugPrint('DEBUG Auth: Sign up response received');
        debugPrint('DEBUG Auth: User ID: ${response.user?.id}');
        debugPrint(
          'DEBUG Auth: Email confirmed: ${response.user?.emailConfirmedAt}',
        );
      }

      if (response.user == null) {
        throw UnknownAuthException('Sign up failed: no user returned');
      }

      // Handle environment-specific email verification
      final requiresEmailVerification = _requiresEmailVerification();
      if (kDebugMode) {
        debugPrint(
          'DEBUG Auth: Requires email verification: $requiresEmailVerification',
        );
      }

      if (requiresEmailVerification &&
          response.user!.emailConfirmedAt == null) {
        // In production/staging, email verification is required
        // The user will need to check their email before they can sign in
        // Note: We still return the user but they may have limited access until verified
      }

      final userDto = AuthUserDto.fromSupabaseUser(response.user!);
      return userDto.toDomain();
    } on supabase.AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Supabase AuthException during sign up');
        debugPrint('DEBUG Auth: Error message: ${e.message}');
        debugPrint('DEBUG Auth: Error code: ${e.code}');
        debugPrint('DEBUG Auth: Status code: ${e.statusCode}');
      }
      throw _mapAuthException(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Unexpected error during sign up');
        debugPrint('DEBUG Auth: Error: $e');
        debugPrint('DEBUG Auth: Stack trace: $stackTrace');
      }
      throw UnknownAuthException(
        'An unexpected error occurred during sign up: $e',
      );
    }
  }

  @override
  Future<domain.AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Attempting sign in for email: $email');
        final currentSession = _supabase.auth.currentSession;
        debugPrint(
          'DEBUG Auth: Current session before signin: ${currentSession?.user.email}',
        );
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('DEBUG Auth: Sign in response received');
        debugPrint('DEBUG Auth: User ID: ${response.user?.id}');
        debugPrint(
          'DEBUG Auth: Email confirmed: ${response.user?.emailConfirmedAt}',
        );
        debugPrint(
          'DEBUG Auth: Session access token present: ${response.session?.accessToken != null}',
        );
      }

      if (response.user == null) {
        throw InvalidCredentialsException();
      }

      // Check if email verification is required
      if (_requiresEmailVerification() &&
          response.user!.emailConfirmedAt == null) {
        if (kDebugMode) {
          debugPrint(
            'DEBUG Auth: Email not verified, but allowing login in staging',
          );
        }
      }

      final userDto = AuthUserDto.fromSupabaseUser(response.user!);
      return userDto.toDomain();
    } on InvalidCredentialsException {
      rethrow;
    } on supabase.AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Supabase AuthException during sign in');
        debugPrint('DEBUG Auth: Error message: ${e.message}');
        debugPrint('DEBUG Auth: Error code: ${e.code}');
        debugPrint('DEBUG Auth: Status code: ${e.statusCode}');
      }
      throw _mapAuthException(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('DEBUG Auth: Unexpected error during sign in');
        debugPrint('DEBUG Auth: Error: $e');
        debugPrint('DEBUG Auth: Stack trace: $stackTrace');
      }
      throw UnknownAuthException(
        'An unexpected error occurred during sign in: $e',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownAuthException(
        'An unexpected error occurred while sending password reset email: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownAuthException(
        'An unexpected error occurred during sign out: $e',
      );
    }
  }

  @override
  Future<domain.AuthUser?> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      final user = response.user;

      if (user == null) return null;

      final userDto = AuthUserDto.fromSupabaseUser(user);
      return userDto.toDomain();
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw UnknownAuthException(
        'An unexpected error occurred while refreshing session: $e',
      );
    }
  }

  /// Maps Supabase AuthExceptions to domain-specific exceptions.
  AuthException _mapAuthException(supabase.AuthException e) {
    final message = e.message.toLowerCase();
    final statusCode = e.statusCode;

    // Map based on common Supabase error messages and status codes
    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password') ||
        statusCode == '400') {
      return InvalidCredentialsException(statusCode);
    }

    if (message.contains('user not found') || statusCode == '404') {
      return UserNotFoundException(statusCode);
    }

    if (message.contains('user already registered') ||
        message.contains('email already registered') ||
        statusCode == '422') {
      return UserAlreadyExistsException(statusCode);
    }

    if (message.contains('email not confirmed') ||
        message.contains('email confirmation required')) {
      return EmailNotConfirmedException(statusCode);
    }

    if (message.contains('password is too weak') ||
        message.contains('weak password')) {
      return WeakPasswordException(statusCode);
    }

    if (message.contains('invalid email format') ||
        message.contains('invalid email')) {
      return InvalidEmailException(statusCode);
    }

    if (message.contains('too many requests') ||
        message.contains('rate limit') ||
        statusCode == '429') {
      return TooManyRequestsException(statusCode);
    }

    if (message.contains('service unavailable') ||
        statusCode == '503' ||
        statusCode == '500') {
      return ServiceUnavailableException(statusCode);
    }

    if (message.contains('session') &&
        (message.contains('expired') || message.contains('invalid'))) {
      return InvalidSessionException(statusCode);
    }

    if (message.contains('network') || message.contains('connection')) {
      return NetworkAuthException(statusCode);
    }

    // Default to unknown exception
    return UnknownAuthException(e.message, statusCode);
  }

  /// Determines if email verification is required based on environment.
  bool _requiresEmailVerification() {
    try {
      final config = EnvConfig.config;
      return config.requireEmailVerification;
    } catch (e) {
      // If environment config is not initialized, assume production behavior
      return true;
    }
  }

  /// Cleanup resources when repository is disposed.
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateController?.close();
  }
}

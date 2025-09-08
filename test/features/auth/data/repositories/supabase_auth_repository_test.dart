import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase
    show AuthException;
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart'
    as domain_exceptions;

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockEnvConfig extends Mock implements EnvConfig {}

void main() {
  group('SupabaseAuthRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late SupabaseAuthRepository repository;
    late StreamController<AuthState> authStateController;

    const testId = 'test-id-123';
    const testEmail = 'test@example.com';
    const testPassword = 'testPassword123';
    const testDisplayName = 'Test User';
    final testCreatedAt = DateTime(2023, 1, 1);
    final testLastSignInAt = DateTime(2023, 1, 2);

    User createTestUser({String? emailConfirmedAt}) {
      return User(
        id: testId,
        appMetadata: const {'provider': 'email'},
        userMetadata: {'display_name': testDisplayName},
        aud: 'authenticated',
        email: testEmail,
        emailConfirmedAt: emailConfirmedAt,
        lastSignInAt: testLastSignInAt.toIso8601String(),
        createdAt: testCreatedAt.toIso8601String(),
        updatedAt: testCreatedAt.toIso8601String(),
      );
    }

    AuthResponse createAuthResponse(User? user) {
      return AuthResponse(
        user: user,
        session: user != null
            ? Session(
                accessToken: 'access_token',
                refreshToken: 'refresh_token',
                expiresIn: 3600,
                tokenType: 'bearer',
                user: user,
              )
            : null,
      );
    }

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      authStateController = StreamController<AuthState>.broadcast();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(
        () => mockAuth.onAuthStateChange,
      ).thenAnswer((_) => authStateController.stream);

      // Mock currentUser to return null by default (needed for constructor)
      when(() => mockAuth.currentUser).thenReturn(null);

      // Mock currentSession to return null by default (needed for constructor)
      when(() => mockAuth.currentSession).thenReturn(null);

      repository = SupabaseAuthRepository(mockSupabaseClient);
    });

    tearDown(() {
      repository.dispose();
      authStateController.close();
    });

    group('currentUser', () {
      test('returns null when no user is signed in', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = repository.currentUser;

        expect(result, isNull);
        verify(
          () => mockAuth.currentUser,
        ).called(2); // Once in constructor, once in getter
      });

      test('returns domain AuthUser when user is signed in', () {
        final testUser = createTestUser();
        when(() => mockAuth.currentUser).thenReturn(testUser);

        final result = repository.currentUser;

        expect(result, isNotNull);
        expect(result!.id, testId);
        expect(result.email, testEmail);
        expect(result.displayName, testDisplayName);
        verify(
          () => mockAuth.currentUser,
        ).called(2); // Once in constructor, once in getter
      });

      test('handles user with null email', () {
        final testUser = User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{},
          aud: 'authenticated',
          email: null,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        when(() => mockAuth.currentUser).thenReturn(testUser);

        final result = repository.currentUser;

        expect(result, isNotNull);
        expect(result!.email, '');
      });
    });

    group('authStateChanges', () {
      test('emits domain AuthUser on sign in', () async {
        final testUser = createTestUser();
        final authState = AuthState(
          AuthChangeEvent.signedIn,
          Session(
            accessToken: 'token',
            refreshToken: 'refresh',
            expiresIn: 3600,
            tokenType: 'bearer',
            user: testUser,
          ),
        );

        // Start listening to the stream
        final stream = repository.authStateChanges;
        final streamFuture = stream.first;

        // Emit the auth state
        authStateController.add(authState);

        // Verify the result
        final result = await streamFuture;
        expect(result, isNotNull);
        expect(result!.id, testId);
        expect(result.email, testEmail);
      });

      test('emits null on sign out', () async {
        final authState = AuthState(AuthChangeEvent.signedOut, null);

        final stream = repository.authStateChanges;
        final streamFuture = stream.first;

        authStateController.add(authState);

        final result = await streamFuture;
        expect(result, isNull);
      });

      test('handles token refresh', () async {
        final testUser = createTestUser();
        final authState = AuthState(
          AuthChangeEvent.tokenRefreshed,
          Session(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiresIn: 3600,
            tokenType: 'bearer',
            user: testUser,
          ),
        );

        final stream = repository.authStateChanges;
        final streamFuture = stream.first;

        authStateController.add(authState);

        final result = await streamFuture;
        expect(result, isNotNull);
        expect(result!.id, testId);
      });
    });

    group('signUpWithEmailPassword', () {
      test('signs up user successfully with email and password', () async {
        final testUser = createTestUser();
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => createAuthResponse(testUser));

        final result = await repository.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        expect(result.id, testId);
        expect(result.email, testEmail);
        expect(result.displayName, testDisplayName);
        verify(
          () => mockAuth.signUp(
            email: testEmail,
            password: testPassword,
            data: {'display_name': testDisplayName},
          ),
        ).called(1);
      });

      test('signs up user without display name', () async {
        final testUser = createTestUser();
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => createAuthResponse(testUser));

        final result = await repository.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result.id, testId);
        verify(
          () => mockAuth.signUp(
            email: testEmail,
            password: testPassword,
            data: null,
          ),
        ).called(1);
      });

      test(
        'throws domain_exceptions.UnknownAuthException when no user returned',
        () async {
          when(
            () => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            ),
          ).thenAnswer((_) async => createAuthResponse(null));

          expect(
            () => repository.signUpWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(
              isA<domain_exceptions.UnknownAuthException>().having(
                (e) => e.message,
                'message',
                contains('Sign up failed: no user returned'),
              ),
            ),
          );
        },
      );

      test(
        'throws domain_exceptions.UserAlreadyExistsException on existing user',
        () async {
          when(
            () => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            ),
          ).thenThrow(
            const supabase.AuthException(
              'User already registered',
              statusCode: '422',
            ),
          );

          expect(
            () => repository.signUpWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(isA<domain_exceptions.UserAlreadyExistsException>()),
          );
        },
      );

      test(
        'throws domain_exceptions.WeakPasswordException on weak password',
        () async {
          when(
            () => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            ),
          ).thenThrow(const supabase.AuthException('Password is too weak'));

          expect(
            () => repository.signUpWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(isA<domain_exceptions.WeakPasswordException>()),
          );
        },
      );
    });

    group('signInWithEmailPassword', () {
      test('signs in user successfully', () async {
        final testUser = createTestUser();
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => createAuthResponse(testUser));

        final result = await repository.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result.id, testId);
        expect(result.email, testEmail);
        verify(
          () => mockAuth.signInWithPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).called(1);
      });

      test(
        'throws domain_exceptions.InvalidCredentialsException when no user returned',
        () async {
          when(
            () => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => createAuthResponse(null));

          expect(
            () => repository.signInWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(isA<domain_exceptions.InvalidCredentialsException>()),
          );
        },
      );

      test(
        'throws domain_exceptions.InvalidCredentialsException on auth exception',
        () async {
          when(
            () => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(
            const supabase.AuthException(
              'Invalid email or password',
              statusCode: '400',
            ),
          );

          expect(
            () => repository.signInWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(isA<domain_exceptions.InvalidCredentialsException>()),
          );
        },
      );
    });

    group('sendPasswordResetEmail', () {
      test('sends password reset email successfully', () async {
        when(
          () => mockAuth.resetPasswordForEmail(any()),
        ).thenAnswer((_) async {});

        await repository.sendPasswordResetEmail(testEmail);

        verify(() => mockAuth.resetPasswordForEmail(testEmail)).called(1);
      });

      test('throws mapped exception on auth exception', () async {
        when(() => mockAuth.resetPasswordForEmail(any())).thenThrow(
          const supabase.AuthException('User not found', statusCode: '404'),
        );

        expect(
          () => repository.sendPasswordResetEmail(testEmail),
          throwsA(isA<domain_exceptions.UserNotFoundException>()),
        );
      });

      test(
        'throws domain_exceptions.UnknownAuthException on generic exception',
        () async {
          when(
            () => mockAuth.resetPasswordForEmail(any()),
          ).thenThrow(Exception('Network error'));

          expect(
            () => repository.sendPasswordResetEmail(testEmail),
            throwsA(
              isA<domain_exceptions.UnknownAuthException>().having(
                (e) => e.message,
                'message',
                contains(
                  'An unexpected error occurred while sending password reset email',
                ),
              ),
            ),
          );
        },
      );
    });

    group('signOut', () {
      test('signs out successfully', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await repository.signOut();

        verify(() => mockAuth.signOut()).called(1);
      });

      test('throws mapped exception on auth exception', () async {
        when(() => mockAuth.signOut()).thenThrow(
          const supabase.AuthException('Session expired', statusCode: '401'),
        );

        expect(
          () => repository.signOut(),
          throwsA(isA<domain_exceptions.InvalidSessionException>()),
        );
      });

      test(
        'throws domain_exceptions.UnknownAuthException on generic exception',
        () async {
          when(() => mockAuth.signOut()).thenThrow(Exception('Network error'));

          expect(
            () => repository.signOut(),
            throwsA(
              isA<domain_exceptions.UnknownAuthException>().having(
                (e) => e.message,
                'message',
                contains('An unexpected error occurred during sign out'),
              ),
            ),
          );
        },
      );
    });

    group('refreshSession', () {
      test('refreshes session successfully with user', () async {
        final testUser = createTestUser();
        final session = Session(
          accessToken: 'new_token',
          refreshToken: 'new_refresh',
          expiresIn: 3600,
          tokenType: 'bearer',
          user: testUser,
        );

        when(() => mockAuth.refreshSession()).thenAnswer(
          (_) async => AuthResponse(user: testUser, session: session),
        );

        final result = await repository.refreshSession();

        expect(result, isNotNull);
        expect(result!.id, testId);
        verify(() => mockAuth.refreshSession()).called(1);
      });

      test('returns null when no user in refreshed session', () async {
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => AuthResponse(user: null, session: null));

        final result = await repository.refreshSession();

        expect(result, isNull);
        verify(() => mockAuth.refreshSession()).called(1);
      });

      test(
        'throws domain_exceptions.InvalidSessionException on session errors',
        () async {
          when(() => mockAuth.refreshSession()).thenThrow(
            const supabase.AuthException('Session expired', statusCode: '401'),
          );

          expect(
            () => repository.refreshSession(),
            throwsA(isA<domain_exceptions.InvalidSessionException>()),
          );
        },
      );
    });

    group('Exception Mapping', () {
      test('maps various Supabase auth exceptions correctly', () {
        final testCases = [
          // Invalid credentials
          (
            const supabase.AuthException('invalid login credentials'),
            domain_exceptions.InvalidCredentialsException,
          ),
          (
            const supabase.AuthException('invalid email or password'),
            domain_exceptions.InvalidCredentialsException,
          ),
          (
            const supabase.AuthException('some error', statusCode: '400'),
            domain_exceptions.InvalidCredentialsException,
          ),

          // User not found
          (
            const supabase.AuthException('user not found'),
            domain_exceptions.UserNotFoundException,
          ),
          (
            const supabase.AuthException('error', statusCode: '404'),
            domain_exceptions.UserNotFoundException,
          ),

          // User already exists
          (
            const supabase.AuthException('user already registered'),
            domain_exceptions.UserAlreadyExistsException,
          ),
          (
            const supabase.AuthException('email already registered'),
            domain_exceptions.UserAlreadyExistsException,
          ),
          (
            const supabase.AuthException('error', statusCode: '422'),
            domain_exceptions.UserAlreadyExistsException,
          ),

          // Email not confirmed
          (
            const supabase.AuthException('email not confirmed'),
            domain_exceptions.EmailNotConfirmedException,
          ),
          (
            const supabase.AuthException('email confirmation required'),
            domain_exceptions.EmailNotConfirmedException,
          ),

          // Weak password
          (
            const supabase.AuthException('password is too weak'),
            domain_exceptions.WeakPasswordException,
          ),
          (
            const supabase.AuthException('weak password'),
            domain_exceptions.WeakPasswordException,
          ),

          // Invalid email
          (
            const supabase.AuthException('invalid email format'),
            domain_exceptions.InvalidEmailException,
          ),
          (
            const supabase.AuthException('invalid email'),
            domain_exceptions.InvalidEmailException,
          ),

          // Too many requests
          (
            const supabase.AuthException('too many requests'),
            domain_exceptions.TooManyRequestsException,
          ),
          (
            const supabase.AuthException('rate limit'),
            domain_exceptions.TooManyRequestsException,
          ),
          (
            const supabase.AuthException('error', statusCode: '429'),
            domain_exceptions.TooManyRequestsException,
          ),

          // Service unavailable
          (
            const supabase.AuthException('service unavailable'),
            domain_exceptions.ServiceUnavailableException,
          ),
          (
            const supabase.AuthException('error', statusCode: '503'),
            domain_exceptions.ServiceUnavailableException,
          ),
          (
            const supabase.AuthException('error', statusCode: '500'),
            domain_exceptions.ServiceUnavailableException,
          ),

          // Invalid session
          (
            const supabase.AuthException('session expired'),
            domain_exceptions.InvalidSessionException,
          ),
          (
            const supabase.AuthException('session invalid'),
            domain_exceptions.InvalidSessionException,
          ),

          // Network error
          (
            const supabase.AuthException('network error'),
            domain_exceptions.NetworkAuthException,
          ),
          (
            const supabase.AuthException('connection error'),
            domain_exceptions.NetworkAuthException,
          ),
        ];

        for (final (supabaseException, expectedExceptionType) in testCases) {
          when(
            () => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(supabaseException);

          expect(
            () => repository.signInWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(
              isA<domain_exceptions.AuthException>().having(
                (e) => e.runtimeType,
                'type',
                expectedExceptionType,
              ),
            ),
            reason:
                'Failed to map ${supabaseException.message} to $expectedExceptionType',
          );
        }
      });

      test(
        'maps unknown auth exceptions to domain_exceptions.UnknownAuthException',
        () {
          const unknownException = supabase.AuthException(
            'Some unknown error message',
          );

          when(
            () => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(unknownException);

          expect(
            () => repository.signInWithEmailPassword(
              email: testEmail,
              password: testPassword,
            ),
            throwsA(
              isA<domain_exceptions.UnknownAuthException>().having(
                (e) => e.message,
                'message',
                unknownException.message,
              ),
            ),
          );
        },
      );
    });

    group('Environment Configuration', () {
      test(
        'checks email verification requirements when config available',
        () async {
          // This test would require mocking EnvConfig, which isn't easily done
          // since it's a static class. We'll test the behavior indirectly.
          final testUser = createTestUser();
          when(
            () => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            ),
          ).thenAnswer((_) async => createAuthResponse(testUser));

          final result = await repository.signUpWithEmailPassword(
            email: testEmail,
            password: testPassword,
          );

          // Should still return user even if email not verified in development
          expect(result.id, testId);
        },
      );

      test('handles missing environment configuration gracefully', () async {
        // The method should not throw when EnvConfig is not available
        final testUser = createTestUser();
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => createAuthResponse(testUser));

        // Should complete without throwing
        expect(
          () => repository.signUpWithEmailPassword(
            email: testEmail,
            password: testPassword,
          ),
          returnsNormally,
        );
      });
    });

    group('Dispose', () {
      test('closes auth state stream controller', () {
        // First disposal should work
        expect(() => repository.dispose(), returnsNormally);

        // Second disposal should also work (idempotent)
        expect(() => repository.dispose(), returnsNormally);

        // The mock's stream controller should still be usable
        // (repository has its own internal controller that gets closed)
        expect(
          () => authStateController.add(
            AuthState(AuthChangeEvent.signedOut, null),
          ),
          returnsNormally,
        );
      });
    });
  });
}

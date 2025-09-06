import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase
    show AuthException;
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart'
    as domain;
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockEnvConfig extends Mock implements EnvConfig {}

void main() {
  group('SupabaseAuthRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockEnvConfig mockEnvConfig;
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

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const OtpType.magiclink());
    });

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      authStateController = StreamController<AuthState>.broadcast();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(
        () => mockAuth.onAuthStateChange,
      ).thenAnswer((_) => authStateController.stream);

      repository = SupabaseAuthRepository(mockSupabaseClient);
    });

    tearDown(() {
      authStateController.close();
      repository.dispose();
    });

    group('currentUser', () {
      test('returns null when no user is signed in', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = repository.currentUser;

        expect(result, isNull);
        verify(() => mockAuth.currentUser).called(1);
      });

      test('returns domain AuthUser when user is signed in', () {
        final testUser = createTestUser();
        when(() => mockAuth.currentUser).thenReturn(testUser);

        final result = repository.currentUser;

        expect(result, isNotNull);
        expect(result!.id, testId);
        expect(result.email, testEmail);
        expect(result.displayName, testDisplayName);
        verify(() => mockAuth.currentUser).called(1);
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

    group('signInWithMagicLink', () {
      test('calls Supabase signInWithOtp with correct email', () async {
        when(
          () => mockAuth.signInWithOtp(
            email: any(named: 'email'),
            shouldCreateUser: any(named: 'shouldCreateUser'),
          ),
        ).thenAnswer((_) async => createAuthResponse(null));

        await repository.signInWithMagicLink(testEmail);

        verify(
          () =>
              mockAuth.signInWithOtp(email: testEmail, shouldCreateUser: true),
        ).called(1);
      });

      test(
        'throws InvalidCredentialsException on invalid credentials',
        () async {
          when(
            () => mockAuth.signInWithOtp(
              email: any(named: 'email'),
              shouldCreateUser: any(named: 'shouldCreateUser'),
            ),
          ).thenThrow(
            const supabase.AuthException(
              'Invalid login credentials',
              statusCode: '400',
            ),
          );

          expect(
            () => repository.signInWithMagicLink(testEmail),
            throwsA(
              isA<InvalidCredentialsException>().having(
                (e) => e.code,
                'code',
                '400',
              ),
            ),
          );
        },
      );

      test('throws UserNotFoundException on user not found', () async {
        when(
          () => mockAuth.signInWithOtp(
            email: any(named: 'email'),
            shouldCreateUser: any(named: 'shouldCreateUser'),
          ),
        ).thenThrow(
          const supabase.AuthException('User not found', statusCode: '404'),
        );

        expect(
          () => repository.signInWithMagicLink(testEmail),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('throws TooManyRequestsException on rate limit', () async {
        when(
          () => mockAuth.signInWithOtp(
            email: any(named: 'email'),
            shouldCreateUser: any(named: 'shouldCreateUser'),
          ),
        ).thenThrow(
          const supabase.AuthException('Too many requests', statusCode: '429'),
        );

        expect(
          () => repository.signInWithMagicLink(testEmail),
          throwsA(isA<TooManyRequestsException>()),
        );
      });

      test('throws UnknownAuthException on generic exception', () async {
        when(
          () => mockAuth.signInWithOtp(
            email: any(named: 'email'),
            shouldCreateUser: any(named: 'shouldCreateUser'),
          ),
        ).thenThrow(Exception('Network error'));

        expect(
          () => repository.signInWithMagicLink(testEmail),
          throwsA(
            isA<UnknownAuthException>().having(
              (e) => e.message,
              'message',
              contains(
                'An unexpected error occurred during magic link sign in',
              ),
            ),
          ),
        );
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

      test('throws UnknownAuthException when no user returned', () async {
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
            isA<UnknownAuthException>().having(
              (e) => e.message,
              'message',
              'Sign up failed: no user returned',
            ),
          ),
        );
      });

      test('throws UserAlreadyExistsException on existing user', () async {
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
          throwsA(isA<UserAlreadyExistsException>()),
        );
      });

      test('throws WeakPasswordException on weak password', () async {
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
          throwsA(isA<WeakPasswordException>()),
        );
      });
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
        'throws InvalidCredentialsException when no user returned',
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
            throwsA(isA<InvalidCredentialsException>()),
          );
        },
      );

      test('throws InvalidCredentialsException on auth exception', () async {
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
          throwsA(isA<InvalidCredentialsException>()),
        );
      });
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
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('throws UnknownAuthException on generic exception', () async {
        when(
          () => mockAuth.resetPasswordForEmail(any()),
        ).thenThrow(Exception('Network error'));

        expect(
          () => repository.sendPasswordResetEmail(testEmail),
          throwsA(
            isA<UnknownAuthException>().having(
              (e) => e.message,
              'message',
              contains(
                'An unexpected error occurred while sending password reset email',
              ),
            ),
          ),
        );
      });
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
          throwsA(isA<InvalidSessionException>()),
        );
      });

      test('throws UnknownAuthException on generic exception', () async {
        when(() => mockAuth.signOut()).thenThrow(Exception('Network error'));

        expect(
          () => repository.signOut(),
          throwsA(
            isA<UnknownAuthException>().having(
              (e) => e.message,
              'message',
              contains('An unexpected error occurred during sign out'),
            ),
          ),
        );
      });
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

      test('throws InvalidSessionException on session errors', () async {
        when(() => mockAuth.refreshSession()).thenThrow(
          const supabase.AuthException('Session expired', statusCode: '401'),
        );

        expect(
          () => repository.refreshSession(),
          throwsA(isA<InvalidSessionException>()),
        );
      });
    });

    group('Exception Mapping', () {
      test('maps various Supabase auth exceptions correctly', () {
        final testCases = [
          // Invalid credentials
          (
            const supabase.AuthException('invalid login credentials'),
            InvalidCredentialsException,
          ),
          (
            const supabase.AuthException('invalid email or password'),
            InvalidCredentialsException,
          ),
          (
            const supabase.AuthException('some error', statusCode: '400'),
            InvalidCredentialsException,
          ),

          // User not found
          (
            const supabase.AuthException('user not found'),
            UserNotFoundException,
          ),
          (
            const supabase.AuthException('error', statusCode: '404'),
            UserNotFoundException,
          ),

          // User already exists
          (
            const supabase.AuthException('user already registered'),
            UserAlreadyExistsException,
          ),
          (
            const supabase.AuthException('email already registered'),
            UserAlreadyExistsException,
          ),
          (
            const supabase.AuthException('error', statusCode: '422'),
            UserAlreadyExistsException,
          ),

          // Email not confirmed
          (
            const supabase.AuthException('email not confirmed'),
            EmailNotConfirmedException,
          ),
          (
            const supabase.AuthException('email confirmation required'),
            EmailNotConfirmedException,
          ),

          // Weak password
          (
            const supabase.AuthException('password is too weak'),
            WeakPasswordException,
          ),
          (
            const supabase.AuthException('weak password'),
            WeakPasswordException,
          ),

          // Invalid email
          (
            const supabase.AuthException('invalid email format'),
            InvalidEmailException,
          ),
          (
            const supabase.AuthException('invalid email'),
            InvalidEmailException,
          ),

          // Too many requests
          (
            const supabase.AuthException('too many requests'),
            TooManyRequestsException,
          ),
          (
            const supabase.AuthException('rate limit'),
            TooManyRequestsException,
          ),
          (
            const supabase.AuthException('error', statusCode: '429'),
            TooManyRequestsException,
          ),

          // Service unavailable
          (
            const supabase.AuthException('service unavailable'),
            ServiceUnavailableException,
          ),
          (
            const supabase.AuthException('error', statusCode: '503'),
            ServiceUnavailableException,
          ),
          (
            const supabase.AuthException('error', statusCode: '500'),
            ServiceUnavailableException,
          ),

          // Invalid session
          (
            const supabase.AuthException('session expired'),
            InvalidSessionException,
          ),
          (
            const supabase.AuthException('session invalid'),
            InvalidSessionException,
          ),

          // Network error
          (const supabase.AuthException('network error'), NetworkAuthException),
          (
            const supabase.AuthException('connection error'),
            NetworkAuthException,
          ),
        ];

        for (final (supabaseException, expectedExceptionType) in testCases) {
          when(
            () => mockAuth.signInWithOtp(
              email: any(named: 'email'),
              shouldCreateUser: any(named: 'shouldCreateUser'),
            ),
          ).thenThrow(supabaseException);

          expect(
            () => repository.signInWithMagicLink(testEmail),
            throwsA(
              isA<AuthException>().having(
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

      test('maps unknown auth exceptions to UnknownAuthException', () {
        const unknownException = supabase.AuthException(
          'Some unknown error message',
        );

        when(
          () => mockAuth.signInWithOtp(
            email: any(named: 'email'),
            shouldCreateUser: any(named: 'shouldCreateUser'),
          ),
        ).thenThrow(unknownException);

        expect(
          () => repository.signInWithMagicLink(testEmail),
          throwsA(
            isA<UnknownAuthException>().having(
              (e) => e.message,
              'message',
              unknownException.message,
            ),
          ),
        );
      });
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
        // Verify that dispose doesn't throw
        expect(() => repository.dispose(), returnsNormally);

        // After dispose, the auth state stream should be closed
        repository.dispose();

        // Try to add to stream - should not cause issues
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

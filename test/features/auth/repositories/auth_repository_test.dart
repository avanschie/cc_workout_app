import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:cc_workout_app/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([supabase.SupabaseClient, supabase.GoTrueClient])
void main() {
  group('SupabaseAuthRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late SupabaseAuthRepository authRepository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();

      // Set up the mock client before creating the repository
      when(mockSupabaseClient.auth).thenReturn(mockAuth);

      // Mock the auth state change stream
      when(mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());

      // Mock currentSession to return null by default
      when(mockAuth.currentSession).thenReturn(null);

      // Mock currentUser to return null by default (needed for constructor)
      when(mockAuth.currentUser).thenReturn(null);

      authRepository = SupabaseAuthRepository(mockSupabaseClient);
    });

    group('currentUser', () {
      test('should return current user from auth client as AuthUser', () {
        final mockUser = supabase.User.fromJson({
          'id': 'user-123',
          'email': 'test@example.com',
          'created_at': '2023-01-01T00:00:00Z',
          'last_sign_in_at': '2023-01-01T00:00:00Z',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'identities': <Map<String, dynamic>>[],
          'aud': 'authenticated',
          'updated_at': '2023-01-01T00:00:00Z',
        });

        when(mockAuth.currentUser).thenReturn(mockUser);

        final result = authRepository.currentUser;

        expect(result, isNotNull);
        expect(result, isA<AuthUser>());
        expect(result!.id, equals('user-123'));
        expect(result.email, equals('test@example.com'));
        verify(
          mockAuth.currentUser,
        ).called(2); // Once in constructor, once in getter
      });

      test('should return null when no user is signed in', () {
        when(mockAuth.currentUser).thenReturn(null);

        final result = authRepository.currentUser;

        expect(result, isNull);
        verify(
          mockAuth.currentUser,
        ).called(2); // Once in constructor, once in getter
      });
    });

    group('authStateChanges', () {
      test('should return auth state changes stream as AuthUser stream', () {
        // The authStateChanges should return a Stream<AuthUser?>
        final stream = authRepository.authStateChanges;

        expect(stream, isA<Stream<AuthUser?>>());
        // Note: Testing the actual stream behavior would require more complex mocking
        // of the Supabase auth state stream, which is handled in integration tests
      });
    });

    group('signInWithMagicLink', () {
      test('should call signInWithOtp with correct email', () async {
        when(
          mockAuth.signInWithOtp(
            email: anyNamed('email'),
            shouldCreateUser: anyNamed('shouldCreateUser'),
          ),
        ).thenAnswer((_) async => supabase.AuthResponse());

        await authRepository.signInWithMagicLink('test@example.com');

        verify(
          mockAuth.signInWithOtp(
            email: 'test@example.com',
            shouldCreateUser: true,
          ),
        ).called(1);
      });

      test('should throw AuthException on Supabase AuthException', () async {
        final authException = supabase.AuthException(
          'Invalid email',
          statusCode: '400',
        );
        when(
          mockAuth.signInWithOtp(
            email: anyNamed('email'),
            shouldCreateUser: anyNamed('shouldCreateUser'),
          ),
        ).thenThrow(authException);

        expect(
          () => authRepository.signInWithMagicLink('invalid@example.com'),
          throwsA(isA<AuthException>()),
        );
      });

      test('should throw UnknownAuthException on generic exception', () async {
        when(
          mockAuth.signInWithOtp(
            email: anyNamed('email'),
            shouldCreateUser: anyNamed('shouldCreateUser'),
          ),
        ).thenThrow(Exception('Network error'));

        expect(
          () => authRepository.signInWithMagicLink('test@example.com'),
          throwsA(isA<UnknownAuthException>()),
        );
      });
    });

    group('signOut', () {
      test('should call auth signOut', () async {
        when(mockAuth.signOut()).thenAnswer((_) async {});

        await authRepository.signOut();

        verify(mockAuth.signOut()).called(1);
      });

      test('should throw AuthException on Supabase AuthException', () async {
        final authException = supabase.AuthException(
          'Sign out failed',
          statusCode: '500',
        );
        when(mockAuth.signOut()).thenThrow(authException);

        expect(() => authRepository.signOut(), throwsA(isA<AuthException>()));
      });

      test('should throw UnknownAuthException on generic exception', () async {
        when(mockAuth.signOut()).thenThrow(Exception('Network error'));

        expect(
          () => authRepository.signOut(),
          throwsA(isA<UnknownAuthException>()),
        );
      });
    });

    group('signUpWithEmailPassword', () {
      test('should return AuthUser on successful sign up', () async {
        final mockUser = supabase.User.fromJson({
          'id': 'user-123',
          'email': 'test@example.com',
          'created_at': '2023-01-01T00:00:00Z',
          'last_sign_in_at': '2023-01-01T00:00:00Z',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{'display_name': 'Test User'},
          'identities': <Map<String, dynamic>>[],
          'aud': 'authenticated',
          'updated_at': '2023-01-01T00:00:00Z',
        });

        final mockResponse = supabase.AuthResponse(
          user: mockUser,
          session: null,
        );

        when(
          mockAuth.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await authRepository.signUpWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(result, isA<AuthUser>());
        expect(result.id, equals('user-123'));
        expect(result.email, equals('test@example.com'));
        expect(result.displayName, equals('Test User'));
        verify(
          mockAuth.signUp(
            email: 'test@example.com',
            password: 'password123',
            data: {'display_name': 'Test User'},
          ),
        ).called(1);
      });
    });

    group('signInWithEmailPassword', () {
      test('should return AuthUser on successful sign in', () async {
        final mockUser = supabase.User.fromJson({
          'id': 'user-123',
          'email': 'test@example.com',
          'created_at': '2023-01-01T00:00:00Z',
          'last_sign_in_at': '2023-01-01T00:00:00Z',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'identities': <Map<String, dynamic>>[],
          'aud': 'authenticated',
          'updated_at': '2023-01-01T00:00:00Z',
        });

        final mockResponse = supabase.AuthResponse(
          user: mockUser,
          session: null,
        );

        when(
          mockAuth.signInWithPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await authRepository.signInWithEmailPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<AuthUser>());
        expect(result.id, equals('user-123'));
        expect(result.email, equals('test@example.com'));
        verify(
          mockAuth.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should call resetPasswordForEmail', () async {
        when(mockAuth.resetPasswordForEmail(any)).thenAnswer((_) async {});

        await authRepository.sendPasswordResetEmail('test@example.com');

        verify(mockAuth.resetPasswordForEmail('test@example.com')).called(1);
      });
    });

    group('refreshSession', () {
      test('should return AuthUser on successful refresh', () async {
        final mockUser = supabase.User.fromJson({
          'id': 'user-123',
          'email': 'test@example.com',
          'created_at': '2023-01-01T00:00:00Z',
          'last_sign_in_at': '2023-01-01T00:00:00Z',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'identities': <Map<String, dynamic>>[],
          'aud': 'authenticated',
          'updated_at': '2023-01-01T00:00:00Z',
        });

        final mockResponse = supabase.AuthResponse(
          user: mockUser,
          session: null,
        );

        when(mockAuth.refreshSession()).thenAnswer((_) async => mockResponse);

        final result = await authRepository.refreshSession();

        expect(result, isA<AuthUser>());
        expect(result!.id, equals('user-123'));
        expect(result.email, equals('test@example.com'));
        verify(mockAuth.refreshSession()).called(1);
      });

      test('should return null when no user', () async {
        final mockResponse = supabase.AuthResponse(user: null, session: null);

        when(mockAuth.refreshSession()).thenAnswer((_) async => mockResponse);

        final result = await authRepository.refreshSession();

        expect(result, isNull);
        verify(mockAuth.refreshSession()).called(1);
      });
    });
  });

  group('AuthException subclasses', () {
    test('InvalidCredentialsException should create with message', () {
      const exception = InvalidCredentialsException();

      expect(exception.message, contains('Invalid'));
      expect(exception.toString(), contains('Invalid email or password'));
    });

    test('UnknownAuthException should create with message and code', () {
      const exception = UnknownAuthException('Test message', '400');

      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('400'));
      expect(exception.toString(), contains('AuthException'));
    });
  });
}

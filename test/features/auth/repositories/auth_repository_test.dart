import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/features/auth/repositories/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient])
void main() {
  group('SupabaseAuthRepository', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late SupabaseAuthRepository authRepository;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      authRepository = SupabaseAuthRepository(mockSupabaseClient);

      when(mockSupabaseClient.auth).thenReturn(mockAuth);
    });

    group('currentUser', () {
      test('should return current user from auth client', () {
        final mockUser = User.fromJson({
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

        expect(result, equals(mockUser));
        verify(mockAuth.currentUser).called(1);
      });

      test('should return null when no user is signed in', () {
        when(mockAuth.currentUser).thenReturn(null);

        final result = authRepository.currentUser;

        expect(result, isNull);
        verify(mockAuth.currentUser).called(1);
      });
    });

    group('authStateChanges', () {
      test('should return auth state changes stream', () {
        final mockStream = Stream<AuthState>.value(
          AuthState(
            AuthChangeEvent.signedIn,
            Session.fromJson({
              'access_token': 'access_token',
              'refresh_token': 'refresh_token',
              'expires_in': 3600,
              'token_type': 'bearer',
              'expires_at':
                  DateTime.now()
                      .add(Duration(hours: 1))
                      .millisecondsSinceEpoch ~/
                  1000,
              'user': {
                'id': 'user-123',
                'email': 'test@example.com',
                'created_at': '2023-01-01T00:00:00Z',
                'last_sign_in_at': '2023-01-01T00:00:00Z',
                'app_metadata': <String, dynamic>{},
                'user_metadata': <String, dynamic>{},
                'identities': <Map<String, dynamic>>[],
                'aud': 'authenticated',
                'updated_at': '2023-01-01T00:00:00Z',
              },
            }),
          ),
        );

        when(mockAuth.onAuthStateChange).thenAnswer((_) => mockStream);

        expect(authRepository.authStateChanges, equals(mockStream));
        verify(mockAuth.onAuthStateChange).called(1);
      });
    });

    group('signInWithMagicLink', () {
      test('should call signInWithOtp with correct email', () async {
        when(
          mockAuth.signInWithOtp(email: anyNamed('email')),
        ).thenAnswer((_) async => AuthResponse());

        await authRepository.signInWithMagicLink('test@example.com');

        verify(mockAuth.signInWithOtp(email: 'test@example.com')).called(1);
      });

      test('should throw AuthRepositoryException on AuthException', () async {
        final authException = AuthException('Invalid email', statusCode: '400');
        when(
          mockAuth.signInWithOtp(email: anyNamed('email')),
        ).thenThrow(authException);

        expect(
          () => authRepository.signInWithMagicLink('invalid@example.com'),
          throwsA(
            isA<AuthRepositoryException>()
                .having((e) => e.message, 'message', 'Invalid email')
                .having((e) => e.statusCode, 'statusCode', '400'),
          ),
        );
      });

      test(
        'should throw AuthRepositoryException on generic exception',
        () async {
          when(
            mockAuth.signInWithOtp(email: anyNamed('email')),
          ).thenThrow(Exception('Network error'));

          expect(
            () => authRepository.signInWithMagicLink('test@example.com'),
            throwsA(
              isA<AuthRepositoryException>()
                  .having(
                    (e) => e.message,
                    'message',
                    'An unexpected error occurred during sign in',
                  )
                  .having((e) => e.statusCode, 'statusCode', isNull),
            ),
          );
        },
      );
    });

    group('signOut', () {
      test('should call auth signOut', () async {
        when(mockAuth.signOut()).thenAnswer((_) async {});

        await authRepository.signOut();

        verify(mockAuth.signOut()).called(1);
      });

      test('should throw AuthRepositoryException on AuthException', () async {
        final authException = AuthException(
          'Sign out failed',
          statusCode: '500',
        );
        when(mockAuth.signOut()).thenThrow(authException);

        expect(
          () => authRepository.signOut(),
          throwsA(
            isA<AuthRepositoryException>()
                .having((e) => e.message, 'message', 'Sign out failed')
                .having((e) => e.statusCode, 'statusCode', '500'),
          ),
        );
      });

      test(
        'should throw AuthRepositoryException on generic exception',
        () async {
          when(mockAuth.signOut()).thenThrow(Exception('Network error'));

          expect(
            () => authRepository.signOut(),
            throwsA(
              isA<AuthRepositoryException>()
                  .having(
                    (e) => e.message,
                    'message',
                    'An unexpected error occurred during sign out',
                  )
                  .having((e) => e.statusCode, 'statusCode', isNull),
            ),
          );
        },
      );
    });
  });

  group('AuthRepositoryException', () {
    test('should create exception with message only', () {
      const exception = AuthRepositoryException('Test message');

      expect(exception.message, equals('Test message'));
      expect(exception.statusCode, isNull);
      expect(
        exception.toString(),
        equals('AuthRepositoryException: Test message'),
      );
    });

    test('should create exception with message and status code', () {
      const exception = AuthRepositoryException('Test message', '400');

      expect(exception.message, equals('Test message'));
      expect(exception.statusCode, equals('400'));
      expect(
        exception.toString(),
        equals('AuthRepositoryException: Test message'),
      );
    });
  });
}

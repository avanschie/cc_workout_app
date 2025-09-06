import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';

void main() {
  group('AuthExceptions', () {
    group('AuthException Base Class', () {
      test('creates exception with message only', () {
        const exception = TestAuthException('Test message');

        expect(exception.message, 'Test message');
        expect(exception.code, isNull);
        expect(exception.toString(), 'AuthException: Test message');
      });

      test('creates exception with message and code', () {
        const exception = TestAuthException('Test message', '400');

        expect(exception.message, 'Test message');
        expect(exception.code, '400');
        expect(exception.toString(), 'AuthException: Test message (code: 400)');
      });
    });

    group('InvalidCredentialsException', () {
      test('creates exception without code', () {
        const exception = InvalidCredentialsException();

        expect(exception.message, 'Invalid email or password');
        expect(exception.code, isNull);
        expect(
          exception.toString(),
          'AuthException: Invalid email or password',
        );
      });

      test('creates exception with code', () {
        const exception = InvalidCredentialsException('400');

        expect(exception.message, 'Invalid email or password');
        expect(exception.code, '400');
        expect(
          exception.toString(),
          'AuthException: Invalid email or password (code: 400)',
        );
      });

      test('is instance of AuthException', () {
        const exception = InvalidCredentialsException();

        expect(exception, isA<AuthException>());
        expect(exception, isA<Exception>());
      });
    });

    group('UserNotFoundException', () {
      test('creates exception without code', () {
        const exception = UserNotFoundException();

        expect(exception.message, 'User not found');
        expect(exception.code, isNull);
        expect(exception.toString(), 'AuthException: User not found');
      });

      test('creates exception with code', () {
        const exception = UserNotFoundException('404');

        expect(exception.message, 'User not found');
        expect(exception.code, '404');
        expect(
          exception.toString(),
          'AuthException: User not found (code: 404)',
        );
      });
    });

    group('UserAlreadyExistsException', () {
      test('creates exception without code', () {
        const exception = UserAlreadyExistsException();

        expect(exception.message, 'User already exists with this email');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = UserAlreadyExistsException('422');

        expect(exception.message, 'User already exists with this email');
        expect(exception.code, '422');
        expect(
          exception.toString(),
          'AuthException: User already exists with this email (code: 422)',
        );
      });
    });

    group('EmailNotConfirmedException', () {
      test('creates exception without code', () {
        const exception = EmailNotConfirmedException();

        expect(exception.message, 'Email confirmation required');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = EmailNotConfirmedException('email_not_confirmed');

        expect(exception.message, 'Email confirmation required');
        expect(exception.code, 'email_not_confirmed');
        expect(
          exception.toString(),
          'AuthException: Email confirmation required (code: email_not_confirmed)',
        );
      });
    });

    group('WeakPasswordException', () {
      test('creates exception without code', () {
        const exception = WeakPasswordException();

        expect(exception.message, 'Password is too weak');
        expect(exception.code, isNull);
        expect(exception.toString(), 'AuthException: Password is too weak');
      });

      test('creates exception with code', () {
        const exception = WeakPasswordException('weak_password');

        expect(exception.message, 'Password is too weak');
        expect(exception.code, 'weak_password');
        expect(
          exception.toString(),
          'AuthException: Password is too weak (code: weak_password)',
        );
      });
    });

    group('InvalidEmailException', () {
      test('creates exception without code', () {
        const exception = InvalidEmailException();

        expect(exception.message, 'Invalid email format');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = InvalidEmailException('invalid_email');

        expect(exception.message, 'Invalid email format');
        expect(exception.code, 'invalid_email');
      });
    });

    group('TooManyRequestsException', () {
      test('creates exception without code', () {
        const exception = TooManyRequestsException();

        expect(exception.message, 'Too many requests. Please try again later');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = TooManyRequestsException('429');

        expect(exception.message, 'Too many requests. Please try again later');
        expect(exception.code, '429');
        expect(
          exception.toString(),
          'AuthException: Too many requests. Please try again later (code: 429)',
        );
      });
    });

    group('ServiceUnavailableException', () {
      test('creates exception without code', () {
        const exception = ServiceUnavailableException();

        expect(
          exception.message,
          'Authentication service is currently unavailable',
        );
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = ServiceUnavailableException('503');

        expect(
          exception.message,
          'Authentication service is currently unavailable',
        );
        expect(exception.code, '503');
      });
    });

    group('InvalidSessionException', () {
      test('creates exception without code', () {
        const exception = InvalidSessionException();

        expect(exception.message, 'Session expired or invalid');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = InvalidSessionException('session_expired');

        expect(exception.message, 'Session expired or invalid');
        expect(exception.code, 'session_expired');
      });
    });

    group('NetworkAuthException', () {
      test('creates exception without code', () {
        const exception = NetworkAuthException();

        expect(exception.message, 'Network error during authentication');
        expect(exception.code, isNull);
      });

      test('creates exception with code', () {
        const exception = NetworkAuthException('network_error');

        expect(exception.message, 'Network error during authentication');
        expect(exception.code, 'network_error');
      });
    });

    group('UnknownAuthException', () {
      test('creates exception with custom message', () {
        const exception = UnknownAuthException('Custom error message');

        expect(exception.message, 'Custom error message');
        expect(exception.code, isNull);
        expect(exception.toString(), 'AuthException: Custom error message');
      });

      test('creates exception with custom message and code', () {
        const exception = UnknownAuthException(
          'Custom error message',
          'custom_code',
        );

        expect(exception.message, 'Custom error message');
        expect(exception.code, 'custom_code');
        expect(
          exception.toString(),
          'AuthException: Custom error message (code: custom_code)',
        );
      });
    });

    group('Exception Hierarchy', () {
      test('all auth exceptions extend AuthException', () {
        const exceptions = [
          InvalidCredentialsException(),
          UserNotFoundException(),
          UserAlreadyExistsException(),
          EmailNotConfirmedException(),
          WeakPasswordException(),
          InvalidEmailException(),
          TooManyRequestsException(),
          ServiceUnavailableException(),
          InvalidSessionException(),
          NetworkAuthException(),
          UnknownAuthException('test'),
        ];

        for (final exception in exceptions) {
          expect(exception, isA<AuthException>());
          expect(exception, isA<Exception>());
        }
      });
    });

    group('Exception Message Uniqueness', () {
      test('all exceptions have unique messages', () {
        final exceptions = [
          InvalidCredentialsException(),
          UserNotFoundException(),
          UserAlreadyExistsException(),
          EmailNotConfirmedException(),
          WeakPasswordException(),
          InvalidEmailException(),
          TooManyRequestsException(),
          ServiceUnavailableException(),
          InvalidSessionException(),
          NetworkAuthException(),
          UnknownAuthException('test'),
        ];

        final messages = exceptions.map((e) => e.message).toSet();

        // All messages should be unique
        expect(messages.length, exceptions.length);
      });
    });

    group('toString Format Consistency', () {
      test('toString follows consistent format', () {
        const testCases = [
          InvalidCredentialsException('400'),
          UserNotFoundException('404'),
          WeakPasswordException('weak'),
          UnknownAuthException('custom message', 'code'),
        ];

        for (final exception in testCases) {
          final stringRep = exception.toString();

          // Should start with 'AuthException: '
          expect(stringRep, startsWith('AuthException: '));

          // Should contain the message
          expect(stringRep, contains(exception.message));

          // If has code, should contain it in parentheses
          if (exception.code != null) {
            expect(stringRep, contains('(code: ${exception.code})'));
          }
        }
      });
    });
  });
}

/// Test class to verify abstract AuthException behavior
class TestAuthException extends AuthException {
  const TestAuthException(super.message, [super.code]);
}

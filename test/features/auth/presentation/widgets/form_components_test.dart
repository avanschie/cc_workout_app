import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/auth/presentation/widgets/form_components.dart';

void main() {
  group('AuthFormValidation', () {
    group('validateEmail', () {
      test('returns empty for empty email', () {
        final result = AuthFormValidation.validateEmail('');
        expect(result, EmailValidationResult.empty);
      });

      test('returns empty for whitespace-only email', () {
        final result = AuthFormValidation.validateEmail('   ');
        expect(result, EmailValidationResult.empty);
      });

      test('returns invalid for malformed email', () {
        final testCases = [
          'invalid',
          'invalid@',
          '@invalid.com',
          'invalid@.com',
          'invalid@com',
          'invalid.email',
          'invalid@email.',
          'invalid@email..com',
          'invalid email@test.com',
          'invalid@email,com',
          'invalid@email com',
        ];

        for (final email in testCases) {
          final result = AuthFormValidation.validateEmail(email);
          expect(
            result,
            EmailValidationResult.invalid,
            reason: 'Failed for email: $email',
          );
        }
      });

      test('returns valid for valid email formats', () {
        final testCases = [
          'test@example.com',
          'user.name@domain.com',
          'user+tag@example.org',
          'user123@test-domain.co.uk',
          'a@b.co',
          'very.long.email.address@very-long-domain-name.com',
          'test.email+tag+sorting@example.com',
          'test_email@example-one.com',
          'test123@123domain.com',
        ];

        for (final email in testCases) {
          final result = AuthFormValidation.validateEmail(email);
          expect(
            result,
            EmailValidationResult.valid,
            reason: 'Failed for email: $email',
          );
        }
      });

      test('trims whitespace before validation', () {
        final result = AuthFormValidation.validateEmail('  test@example.com  ');
        expect(result, EmailValidationResult.valid);
      });
    });

    group('validatePassword', () {
      test('returns empty for empty password', () {
        final result = AuthFormValidation.validatePassword('');
        expect(result, PasswordValidationResult.empty);
      });

      test('returns tooShort for passwords under minimum length', () {
        final testCases = [
          'a',
          'ab',
          'abc',
          'abcd',
          'abcde',
          'abcdef',
          'abcdefg', // 7 characters, minimum is 8
        ];

        for (final password in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          expect(
            result,
            PasswordValidationResult.tooShort,
            reason: 'Failed for password length: ${password.length}',
          );
        }
      });

      test('returns tooWeak for passwords without letters', () {
        final testCases = [
          '12345678',
          '87654321',
          '12345678901234',
          '!@#\$%^&*()',
          '123456789!',
        ];

        for (final password in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          expect(
            result,
            PasswordValidationResult.tooWeak,
            reason: 'Failed for password: $password',
          );
        }
      });

      test('returns tooWeak for passwords without numbers', () {
        final testCases = [
          'abcdefgh',
          'password',
          'ABCDEFGH',
          'AbCdEfGh',
          'password!',
        ];

        for (final password in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          expect(
            result,
            PasswordValidationResult.tooWeak,
            reason: 'Failed for password: $password',
          );
        }
      });

      test('returns valid for passwords with letters and numbers', () {
        final testCases = [
          'abcdef12',
          'Password1',
          'Test123456',
          'MyPassword123',
          '1abcdefg',
          'abc123XYZ',
          'StrongPass1',
        ];

        for (final password in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          expect(
            result,
            PasswordValidationResult.valid,
            reason: 'Failed for password: $password',
          );
        }
      });

      test('handles special characters correctly', () {
        // Special characters should not affect validation if letters and numbers are present
        final testCases = [
          'Password1!',
          'Test@123',
          'MyPass#123',
          'Strong\$Pass1',
          'Test_Pass123',
        ];

        for (final password in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          expect(
            result,
            PasswordValidationResult.valid,
            reason: 'Failed for password: $password',
          );
        }
      });

      test('validates minimum password length constant', () {
        expect(AuthFormValidation.minPasswordLength, equals(8));
      });
    });

    group('getEmailErrorMessage', () {
      test('returns null for valid email', () {
        final message = AuthFormValidation.getEmailErrorMessage(
          EmailValidationResult.valid,
        );
        expect(message, isNull);
      });

      test('returns error message for empty email', () {
        final message = AuthFormValidation.getEmailErrorMessage(
          EmailValidationResult.empty,
        );
        expect(message, isNotNull);
        expect(message!.toLowerCase(), contains('email'));
        expect(message, contains('required'));
      });

      test('returns error message for invalid email', () {
        final message = AuthFormValidation.getEmailErrorMessage(
          EmailValidationResult.invalid,
        );
        expect(message, isNotNull);
        expect(message, contains('valid'));
        expect(message!.toLowerCase(), contains('email'));
      });
    });

    group('getPasswordErrorMessage', () {
      test('returns null for valid password', () {
        final message = AuthFormValidation.getPasswordErrorMessage(
          PasswordValidationResult.valid,
        );
        expect(message, isNull);
      });

      test('returns error message for empty password', () {
        final message = AuthFormValidation.getPasswordErrorMessage(
          PasswordValidationResult.empty,
        );
        expect(message, isNotNull);
        expect(message!.toLowerCase(), contains('password'));
        expect(message, contains('required'));
      });

      test('returns error message for too short password', () {
        final message = AuthFormValidation.getPasswordErrorMessage(
          PasswordValidationResult.tooShort,
        );
        expect(message, isNotNull);
        expect(message, contains('8'));
        expect(message, contains('character'));
      });

      test('returns error message for weak password', () {
        final message = AuthFormValidation.getPasswordErrorMessage(
          PasswordValidationResult.tooWeak,
        );
        expect(message, isNotNull);
        expect(message, contains('letter'));
        expect(message, contains('number'));
      });
    });

    group('Email Regex Pattern', () {
      test('regex is accessible and functional', () {
        // We can't directly access the private regex, but we can test it through validateEmail
        expect(
          AuthFormValidation.validateEmail('test@example.com'),
          EmailValidationResult.valid,
        );
        expect(
          AuthFormValidation.validateEmail('invalid'),
          EmailValidationResult.invalid,
        );
      });
    });

    group('Edge Cases', () {
      test('handles extremely long valid email', () {
        final longEmail = '${'a' * 50}@${'b' * 50}.com';
        final result = AuthFormValidation.validateEmail(longEmail);
        expect(result, EmailValidationResult.valid);
      });

      test('handles extremely long invalid email', () {
        final longInvalid = 'a' * 100; // No @ symbol
        final result = AuthFormValidation.validateEmail(longInvalid);
        expect(result, EmailValidationResult.invalid);
      });

      test('handles extremely long password', () {
        final longPassword =
            'a' * 100 + '1'; // Over 100 characters with letter and number
        final result = AuthFormValidation.validatePassword(longPassword);
        expect(result, PasswordValidationResult.valid);
      });

      test('handles password with mixed case and numbers', () {
        final result = AuthFormValidation.validatePassword('AbCdEf123');
        expect(result, PasswordValidationResult.valid);
      });

      test('handles international characters in email', () {
        // Basic international domain test
        final result = AuthFormValidation.validateEmail('test@müller.de');
        // Note: Our current regex might not support international domains
        // This test documents current behavior
        expect(result, EmailValidationResult.invalid);
      });

      test('handles unicode characters in password', () {
        final result = AuthFormValidation.validatePassword('pässwörd123');
        expect(result, PasswordValidationResult.valid);
      });
    });

    group('Validation Integration', () {
      test('validateEmail and getEmailErrorMessage work together', () {
        final testCases = [
          ('', EmailValidationResult.empty),
          ('invalid', EmailValidationResult.invalid),
          ('test@example.com', EmailValidationResult.valid),
        ];

        for (final (email, expectedResult) in testCases) {
          final result = AuthFormValidation.validateEmail(email);
          final message = AuthFormValidation.getEmailErrorMessage(result);

          expect(result, expectedResult);
          if (expectedResult == EmailValidationResult.valid) {
            expect(message, isNull);
          } else {
            expect(message, isNotNull);
          }
        }
      });

      test('validatePassword and getPasswordErrorMessage work together', () {
        final testCases = [
          ('', PasswordValidationResult.empty),
          ('short', PasswordValidationResult.tooShort),
          ('nodigits', PasswordValidationResult.tooWeak),
          ('12345678', PasswordValidationResult.tooWeak),
          ('Valid123', PasswordValidationResult.valid),
        ];

        for (final (password, expectedResult) in testCases) {
          final result = AuthFormValidation.validatePassword(password);
          final message = AuthFormValidation.getPasswordErrorMessage(result);

          expect(result, expectedResult);
          if (expectedResult == PasswordValidationResult.valid) {
            expect(message, isNull);
          } else {
            expect(message, isNotNull);
          }
        }
      });
    });

    group('Form Validation Performance', () {
      test('email validation handles rapid successive calls', () {
        final emails = List.generate(1000, (i) => 'test$i@example.com');

        final stopwatch = Stopwatch()..start();
        for (final email in emails) {
          AuthFormValidation.validateEmail(email);
        }
        stopwatch.stop();

        // Should complete in reasonable time (less than 1 second for 1000 validations)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('password validation handles rapid successive calls', () {
        final passwords = List.generate(1000, (i) => 'password$i');

        final stopwatch = Stopwatch()..start();
        for (final password in passwords) {
          AuthFormValidation.validatePassword(password);
        }
        stopwatch.stop();

        // Should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}

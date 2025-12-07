import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';
import 'package:cc_workout_app/features/auth/presentation/widgets/form_components.dart';
import '../../../../test_robots/auth_robot.dart';

// Mock classes would typically be generated with mockito
class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return super.noSuchMethod(
      Invocation.method(#signInWithEmailPassword, [], {
        #email: email,
        #password: password,
      }),
      returnValue: Future.value(
        AuthUser(
          id: 'test-id',
          email: email,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) {
    return super.noSuchMethod(
      Invocation.method(#signUpWithEmailPassword, [], {
        #email: email,
        #password: password,
        #displayName: displayName,
      }),
      returnValue: Future.value(
        AuthUser(
          id: 'test-id',
          email: email,
          displayName: displayName,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<void> signOut() {
    return super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future.value(),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return super.noSuchMethod(
      Invocation.method(#sendPasswordResetEmail, [email]),
      returnValue: Future.value(),
    );
  }

  @override
  Future<void> refresh() {
    return super.noSuchMethod(
      Invocation.method(#refresh, []),
      returnValue: Future.value(),
    );
  }

  @override
  Future<AuthUser?> build() {
    return super.noSuchMethod(
      Invocation.method(#build, []),
      returnValue: Future.value(null),
    );
  }
}

void main() {
  group('SignInScreen Robot Tests', () {
    late MockAuthNotifier mockAuthNotifier;
    late AuthRobot authRobot;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
    });

    Widget createSignInScreen() {
      return ProviderScope(
        overrides: [
          // Override providers for testing
          authNotifierProvider.overrideWith(() => mockAuthNotifier),
        ],
        child: const MaterialApp(home: SignInScreen()),
      );
    }

    testWidgets('should display sign in form elements', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Act & Assert
      authRobot.expectToBeOnSignInScreen();
      expect(authRobot.emailField, findsOneWidget);
      expect(authRobot.passwordField, findsOneWidget);
      expect(authRobot.signInButton, findsOneWidget);
      expect(authRobot.forgotPasswordButton, findsOneWidget);
      expect(authRobot.goToSignUpButton, findsOneWidget);
    });

    testWidgets('should validate empty email and password', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Act - try to sign in with empty fields
      await authRobot.tapSignIn();

      // Assert
      authRobot.expectEmailValidationError('Email is required');
      authRobot.expectPasswordValidationError('Password is required');
    });

    testWidgets('should validate invalid email format', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Act
      await authRobot.enterEmail('invalid-email');
      await authRobot.enterPassword('password123');
      await authRobot.tapSignIn();

      // Assert
      authRobot.expectEmailValidationError(
        'Please enter a valid email address',
      );
    });

    testWidgets('should display sign in button', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Assert - button should be present and enabled
      expect(authRobot.signInButton, findsOneWidget);
      authRobot.expectSignInButtonEnabled();
    });

    testWidgets('should allow entering email and password', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Act
      await authRobot.enterEmail('test@example.com');
      await authRobot.enterPassword('password123');

      // Assert - values should be entered
      expect(find.text('test@example.com'), findsOneWidget);
      // Password is obscured so we can't test the text directly
      expect(authRobot.passwordField, findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Act & Assert
      authRobot.expectPasswordVisible(false); // Initially hidden

      await authRobot.togglePasswordVisibility();
      authRobot.expectPasswordVisible(true); // Now visible

      await authRobot.togglePasswordVisibility();
      authRobot.expectPasswordVisible(false); // Hidden again
    });

    testWidgets('should navigate to sign up screen', (tester) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sign-up': (context) =>
                const Scaffold(body: Text('Sign Up Screen')),
          },
          home: ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith(() => mockAuthNotifier),
            ],
            child: const SignInScreen(),
          ),
        ),
      );
      authRobot = AuthRobot(tester);

      // Act
      await authRobot.goToSignUp();

      // Assert
      expect(find.text('Sign Up Screen'), findsOneWidget);
    });

    testWidgets('should always enable sign in button (validation on submit)', (
      tester,
    ) async {
      // Arrange
      when(mockAuthNotifier.build()).thenAnswer((_) async => null);

      await tester.pumpWidget(createSignInScreen());
      authRobot = AuthRobot(tester);

      // Button should always be enabled (form validation happens on submit)
      authRobot.expectSignInButtonEnabled();

      // Act
      await authRobot.enterEmail('test@example.com');
      await authRobot.enterPassword('password123');

      // Assert - still enabled
      authRobot.expectSignInButtonEnabled();
    });
  });
}

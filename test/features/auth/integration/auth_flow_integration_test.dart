import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/auth_gate.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/forgot_password_screen.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

/// Integration test robot for auth flows
class AuthFlowRobot {
  const AuthFlowRobot(this.tester);

  final WidgetTester tester;

  // Setup methods
  Future<MockAuthRepository> setupApp({AuthUser? initialUser}) async {
    final mockRepository = MockAuthRepository();
    final authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockRepository.currentUser).thenReturn(initialUser);
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => authStateController.stream);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
        child: const AuthGate(),
      ),
    );

    return mockRepository;
  }

  // Navigation actions
  Future<void> navigateToSignUp() async {
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();
  }

  Future<void> navigateToSignIn() async {
    await tester.tap(find.text("Already have an account? Sign in"));
    await tester.pumpAndSettle();
  }

  Future<void> navigateToForgotPassword() async {
    await tester.tap(find.text("Forgot your password?"));
    await tester.pumpAndSettle();
  }

  Future<void> navigateBack() async {
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  // Form actions
  Future<void> enterEmail(String email) async {
    await tester.enterText(find.byKey(const Key('email_field')), email);
  }

  Future<void> enterPassword(String password) async {
    await tester.enterText(find.byKey(const Key('password_field')), password);
  }

  Future<void> enterConfirmPassword(String password) async {
    await tester.enterText(
      find.byKey(const Key('confirm_password_field')),
      password,
    );
  }

  Future<void> enterDisplayName(String displayName) async {
    await tester.enterText(
      find.byKey(const Key('display_name_field')),
      displayName,
    );
  }

  Future<void> tapSignInButton() async {
    await tester.tap(find.byKey(const Key('sign_in_button')));
    await tester.pumpAndSettle();
  }

  Future<void> tapSignUpButton() async {
    await tester.tap(find.byKey(const Key('sign_up_button')));
    await tester.pumpAndSettle();
  }

  Future<void> tapMagicLinkButton() async {
    await tester.tap(find.byKey(const Key('magic_link_button')));
    await tester.pumpAndSettle();
  }

  Future<void> tapResetPasswordButton() async {
    await tester.tap(find.byKey(const Key('reset_password_button')));
    await tester.pumpAndSettle();
  }

  Future<void> tapSignOutButton() async {
    await tester.tap(find.byKey(const Key('sign_out_button')));
    await tester.pumpAndSettle();
  }

  // Assertions
  void expectSignInScreen() {
    expect(find.byType(SignInScreen), findsOneWidget);
  }

  void expectSignUpScreen() {
    expect(find.byType(SignUpScreen), findsOneWidget);
  }

  void expectForgotPasswordScreen() {
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  }

  void expectMainApp() {
    expect(find.text('Rep Max Tracker'), findsOneWidget);
  }

  void expectError(String errorText) {
    expect(find.textContaining(errorText), findsOneWidget);
  }

  void expectLoading() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  void expectNoError() {
    expect(find.textContaining('error', findRichText: true), findsNothing);
    expect(find.textContaining('Error', findRichText: true), findsNothing);
  }
}

AuthUser createTestUser({
  String id = 'test-user-123',
  String email = 'test@example.com',
  String? displayName = 'Test User',
}) {
  return AuthUser(
    id: id,
    email: email,
    displayName: displayName,
    isEmailVerified: true,
    createdAt: DateTime(2023, 1, 1),
  );
}

void main() {
  group('Auth Flow Integration Tests', () {
    setUpAll(() {
      registerFallbackValue(const InvalidCredentialsException());
    });

    testWidgets('complete sign up to sign in flow', (tester) async {
      final robot = AuthFlowRobot(tester);
      const testEmail = 'test@example.com';
      const testPassword = 'TestPass123';
      const testDisplayName = 'Test User';

      final mockRepository = await robot.setupApp();

      // Set up successful sign up
      final testUser = createTestUser(
        email: testEmail,
        displayName: testDisplayName,
      );
      when(
        () => mockRepository.signUpWithEmailPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => testUser);

      // Start with sign in screen, navigate to sign up
      robot.expectSignInScreen();
      await robot.navigateToSignUp();
      robot.expectSignUpScreen();

      // Fill out sign up form
      await robot.enterDisplayName(testDisplayName);
      await robot.enterEmail(testEmail);
      await robot.enterPassword(testPassword);
      await robot.enterConfirmPassword(testPassword);

      // Submit sign up
      await robot.tapSignUpButton();

      // Verify repository was called
      verify(
        () => mockRepository.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        ),
      ).called(1);
    });

    testWidgets('sign in with email and password flow', (tester) async {
      const testEmail = 'test@example.com';
      const testPassword = 'TestPass123';

      final mockRepository = await robot.setupApp();

      // Set up successful sign in
      final testUser = createTestUser(email: testEmail);
      when(
        () => mockRepository.signInWithEmailPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testUser);

      robot.expectSignInScreen();

      // Fill out sign in form
      await robot.enterEmail(testEmail);
      await robot.enterPassword(testPassword);

      // Submit sign in
      await robot.tapSignInButton();

      // Verify repository was called
      verify(
        () => mockRepository.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    testWidgets('magic link sign in flow', (tester) async {
      const testEmail = 'test@example.com';

      final mockRepository = await robot.setupApp();

      // Set up successful magic link
      when(
        () => mockRepository.signInWithMagicLink(any()),
      ).thenAnswer((_) async {});

      robot.expectSignInScreen();

      // Fill email and use magic link
      await robot.enterEmail(testEmail);
      await robot.tapMagicLinkButton();

      // Verify repository was called
      verify(() => mockRepository.signInWithMagicLink(testEmail)).called(1);
    });

    testWidgets('forgot password flow', (tester) async {
      const testEmail = 'test@example.com';

      final mockRepository = await robot.setupApp();

      // Set up successful password reset
      when(
        () => mockRepository.sendPasswordResetEmail(any()),
      ).thenAnswer((_) async {});

      robot.expectSignInScreen();

      // Navigate to forgot password
      await robot.navigateToForgotPassword();
      robot.expectForgotPasswordScreen();

      // Enter email and submit
      await robot.enterEmail(testEmail);
      await robot.tapResetPasswordButton();

      // Verify repository was called
      verify(() => mockRepository.sendPasswordResetEmail(testEmail)).called(1);
    });

    testWidgets('error handling during sign in', (tester) async {
      const testEmail = 'test@example.com';
      const testPassword = 'WrongPassword';

      final mockRepository = await robot.setupApp();

      // Set up sign in to throw error
      when(
        () => mockRepository.signInWithEmailPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsException());

      robot.expectSignInScreen();

      // Fill out form with invalid credentials
      await robot.enterEmail(testEmail);
      await robot.enterPassword(testPassword);

      // Submit sign in
      await robot.tapSignInButton();

      // Should show error message
      robot.expectError('Invalid email or password');

      // Verify repository was called
      verify(
        () => mockRepository.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    testWidgets('navigation between auth screens', (tester) async {
      await robot.setupApp();

      // Start at sign in
      robot.expectSignInScreen();

      // Navigate to sign up
      await robot.navigateToSignUp();
      robot.expectSignUpScreen();

      // Navigate back to sign in
      await robot.navigateToSignIn();
      robot.expectSignInScreen();

      // Navigate to forgot password
      await robot.navigateToForgotPassword();
      robot.expectForgotPasswordScreen();

      // Navigate back
      await robot.navigateBack();
      robot.expectSignInScreen();
    });

    testWidgets('authenticated user sees main app', (tester) async {
      final testUser = createTestUser();
      await robot.setupApp(initialUser: testUser);

      // Should immediately show main app
      robot.expectMainApp();
    });

    testWidgets('sign out flow returns to auth screens', (tester) async {
      final testUser = createTestUser();
      final mockRepository = await robot.setupApp(initialUser: testUser);

      // Set up successful sign out
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      // Should start at main app
      robot.expectMainApp();

      // Sign out (this would typically be triggered from a menu or button)
      await robot.tapSignOutButton();

      // Should return to auth screens
      robot.expectSignInScreen();

      verify(() => mockRepository.signOut()).called(1);
    });

    testWidgets('form validation prevents invalid submissions', (tester) async {
      await robot.setupApp();

      robot.expectSignInScreen();

      // Try to submit without filling anything
      await robot.tapSignInButton();

      // Should not proceed and show validation errors
      robot.expectSignInScreen();

      // Try with invalid email
      await robot.enterEmail('invalid-email');
      await robot.enterPassword('ValidPass123');
      await robot.tapSignInButton();

      // Should still be on sign in screen with error
      robot.expectSignInScreen();
    });

    testWidgets('network errors are handled gracefully', (tester) async {
      final mockRepository = await robot.setupApp();

      // Set up network error
      when(
        () => mockRepository.signInWithEmailPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkAuthException());

      robot.expectSignInScreen();

      await robot.enterEmail('test@example.com');
      await robot.enterPassword('TestPass123');
      await robot.tapSignInButton();

      // Should show network error message
      robot.expectError('Network error during authentication');
    });

    testWidgets('concurrent auth operations are handled correctly', (
      tester,
    ) async {
      final mockRepository = await robot.setupApp();

      // Set up delayed responses to simulate race conditions
      when(
        () => mockRepository.signInWithEmailPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return createTestUser();
      });

      when(() => mockRepository.signInWithMagicLink(any())).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });

      robot.expectSignInScreen();

      // Trigger multiple operations rapidly
      await robot.enterEmail('test@example.com');
      await robot.enterPassword('TestPass123');

      // Start both operations without waiting
      await robot.tapSignInButton();
      await robot.tapMagicLinkButton();

      // Wait for operations to complete
      await tester.pumpAndSettle();

      // Should handle gracefully without crashes
      robot.expectNoError();
    });
  });
}

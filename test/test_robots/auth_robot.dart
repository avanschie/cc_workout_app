import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/widgets/form_components.dart';
import 'base_robot.dart';

/// Robot class for testing authentication-related UI interactions
///
/// This robot provides a high-level API for testing authentication flows,
/// encapsulating the low-level widget interactions and making tests more
/// readable and maintainable.
class AuthRobot extends BaseRobot {
  const AuthRobot(super.tester);

  // Finders for common auth elements
  Finder get emailField => find.byKey(const Key('email_field'));
  Finder get passwordField => find.byKey(const Key('password_field'));
  Finder get displayNameField => find.byKey(const Key('display_name_field'));
  Finder get signInButton => find.byKey(const Key('sign_in_button'));
  Finder get signUpButton => find.byKey(const Key('sign_up_button'));
  Finder get forgotPasswordButton => find.text('Forgot your password?');
  Finder get goToSignUpButton => find.text('Create new account');
  Finder get goToSignInButton => find.text('Already have an account? Sign In');
  Finder get passwordVisibilityToggle =>
      find.byType(IconButton).last; // Last IconButton in password field

  // Error and loading states
  @override
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  @override
  Finder get errorSnackBar => find.byType(SnackBar);
  Finder emailErrorText(String error) => find.text(error);
  Finder passwordErrorText(String error) => find.text(error);

  /// Enter email in the email field
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
  }

  /// Enter password in the password field
  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
  }

  /// Enter display name in the display name field (sign up only)
  Future<void> enterDisplayName(String displayName) async {
    await tester.enterText(displayNameField, displayName);
    await tester.pumpAndSettle();
  }

  /// Tap the sign in button
  Future<void> tapSignIn() async {
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }

  /// Tap the sign up button
  Future<void> tapSignUp() async {
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
  }

  /// Tap the forgot password button
  Future<void> tapForgotPassword() async {
    await tester.tap(forgotPasswordButton);
    await tester.pumpAndSettle();
  }

  /// Navigate to sign up screen
  Future<void> goToSignUp() async {
    await tester.tap(goToSignUpButton);
    await tester.pumpAndSettle();
  }

  /// Navigate to sign in screen
  Future<void> goToSignIn() async {
    await tester.tap(goToSignInButton);
    await tester.pumpAndSettle();
  }

  /// Toggle password visibility
  Future<void> togglePasswordVisibility() async {
    await tester.tap(passwordVisibilityToggle);
    await tester.pumpAndSettle();
  }

  /// Complete sign in flow with email and password
  Future<void> signInWith({
    required String email,
    required String password,
  }) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapSignIn();
  }

  /// Complete sign up flow with email, password, and display name
  Future<void> signUpWith({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await enterEmail(email);
    await enterPassword(password);
    await enterDisplayName(displayName);
    await tapSignUp();
  }

  // Verification methods

  /// Verify that we're on the sign in screen
  void expectToBeOnSignInScreen() {
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(signInButton, findsOneWidget);
  }

  /// Verify that we're on the sign up screen
  void expectToBeOnSignUpScreen() {
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(signUpButton, findsOneWidget);
    expect(displayNameField, findsOneWidget);
  }

  /// Verify that a loading indicator is shown
  void expectLoadingIndicator() {
    expect(loadingIndicator, findsOneWidget);
  }

  /// Verify that no loading indicator is shown
  void expectNoLoadingIndicator() {
    expect(loadingIndicator, findsNothing);
  }

  /// Verify that an error message is displayed
  @override
  void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Verify that no error message is displayed
  void expectNoErrorMessage() {
    expect(errorSnackBar, findsNothing);
  }

  /// Verify that email validation error is shown
  void expectEmailValidationError(String error) {
    expect(emailErrorText(error), findsOneWidget);
  }

  /// Verify that password validation error is shown
  void expectPasswordValidationError(String error) {
    expect(passwordErrorText(error), findsOneWidget);
  }

  /// Verify that the sign in button is enabled
  void expectSignInButtonEnabled() {
    final button = tester.widget<AuthSubmitButton>(signInButton);
    expect(button.isEnabled && !button.isLoading, isTrue);
  }

  /// Verify that the sign in button is disabled
  void expectSignInButtonDisabled() {
    final button = tester.widget<AuthSubmitButton>(signInButton);
    expect(button.isEnabled && !button.isLoading, isFalse);
  }

  /// Verify password field visibility state
  void expectPasswordVisible(bool visible) {
    // Find the TextField inside the TextFormField
    final textField = tester.widget<TextField>(
      find.descendant(of: passwordField, matching: find.byType(TextField)),
    );
    expect(textField.obscureText, !visible);
  }
}

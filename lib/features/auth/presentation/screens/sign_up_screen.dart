import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/auth_providers.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../widgets/form_components.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/config/env_config.dart';

/// Sign up screen with email/password registration
///
/// Features:
/// - Email, password, and optional display name form
/// - Real-time validation with password strength indicator
/// - Password confirmation field
/// - Loading states during registration
/// - Error handling with user-friendly messages
/// - Navigation back to sign in screen
/// - Environment-specific behavior and messaging
/// - Terms of service and privacy policy acceptance
/// - Responsive layout with keyboard handling
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _displayNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _emailFocusNode.dispose();
    _displayNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 750;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              _buildHeader(theme, colorScheme, isSmallScreen),

              SizedBox(height: isSmallScreen ? 24 : 32),

              // Form section
              _buildForm(theme),

              const SizedBox(height: 24),

              // Terms acceptance
              _buildTermsAcceptance(theme),

              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(theme),

              const SizedBox(height: 16),

              // Sign in link
              _buildSignInLink(theme),

              // Environment info
              if (_shouldShowEnvironmentInfo()) ...[
                const SizedBox(height: 24),
                _buildEnvironmentInfo(theme, colorScheme),
              ],

              // Bottom spacing
              SizedBox(height: isSmallScreen ? 20 : 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        // App Icon
        Container(
          width: isSmallScreen ? 56 : 64,
          height: isSmallScreen ? 56 : 64,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.fitness_center,
            size: isSmallScreen ? 28 : 32,
            color: colorScheme.onPrimary,
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Welcome text
        Text(
          'Join Rep Max Tracker',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 24 : null,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Create your account to start tracking your powerlifting progress',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AuthEmailField(
            controller: _emailController,
            enabled: !_isLoading,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: () {
              FocusScope.of(context).requestFocus(_displayNameFocusNode);
            },
          ),

          const SizedBox(height: 16),

          // Display name field (optional)
          AuthDisplayNameField(
            controller: _displayNameController,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: () {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),

          const SizedBox(height: 16),

          // Password field
          AuthPasswordField(
            controller: _passwordController,
            enabled: !_isLoading,
            showStrengthIndicator: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: () {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            },
          ),

          const SizedBox(height: 16),

          // Confirm password field
          AuthPasswordField(
            controller: _confirmPasswordController,
            enabled: !_isLoading,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            textInputAction: TextInputAction.done,
            isConfirmationField: true,
            originalPasswordController: _passwordController,
            onFieldSubmitted: _acceptedTerms ? _handleSignUp : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAcceptance(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () {
                    setState(() {
                      _acceptedTerms = !_acceptedTerms;
                    });
                  },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: theme.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return AuthSubmitButton(
      key: const Key('sign_up_button'),
      onPressed: _acceptedTerms ? _handleSignUp : null,
      text: 'Create Account',
      isLoading: _isLoading,
      isEnabled: _acceptedTerms && !_isLoading,
      icon: Icons.person_add,
    );
  }

  Widget _buildSignInLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: Text.rich(
          TextSpan(
            text: 'Already have an account? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentInfo(ThemeData theme, ColorScheme colorScheme) {
    final environment = EnvConfig.environment;
    final config = EnvConfig.config;

    String environmentText;
    IconData environmentIcon;
    Color environmentColor;

    switch (environment) {
      case Environment.local:
        environmentText = config.requireEmailVerification
            ? 'Local Dev (Email verification required)'
            : 'Local Dev (No email verification)';
        environmentIcon = Icons.developer_mode;
        environmentColor = Colors.orange;
        break;
      case Environment.staging:
        environmentText = 'Staging Environment';
        environmentIcon = Icons.science;
        environmentColor = Colors.blue;
        break;
      case Environment.production:
        return const SizedBox.shrink(); // Don't show in production
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: environmentColor.withValues(alpha: 0.1),
        border: Border.all(color: environmentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(environmentIcon, size: 16, color: environmentColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              environmentText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: environmentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowEnvironmentInfo() {
    try {
      return EnvConfig.environment != Environment.production;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      SnackBarUtils.showError(
        context,
        'Please accept the Terms of Service and Privacy Policy',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider);
      await authController.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
      );

      if (mounted) {
        final config = EnvConfig.config;

        if (config.requireEmailVerification) {
          SnackBarUtils.showSuccess(
            context,
            'Account created! Please check your email to verify your account.',
          );
          Navigator.of(context).pop(); // Return to sign in screen
        } else {
          SnackBarUtils.showSuccess(
            context,
            'Account created successfully! Welcome to Rep Max Tracker.',
          );
          // Navigation handled by auth state change
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, _getAuthErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(AuthException exception) {
    if (exception is UserAlreadyExistsException) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (exception is WeakPasswordException) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (exception is InvalidEmailException) {
      return 'Please enter a valid email address.';
    } else if (exception is NetworkAuthException) {
      return 'Network error. Please check your connection and try again.';
    } else if (exception is ServiceUnavailableException) {
      return 'Server error. Please try again in a few moments.';
    } else if (exception is TooManyRequestsException) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'Sign up failed. Please try again.';
    }
  }
}

/// Provider for managing sign up form state (if needed for more complex state management)
final signUpFormProvider =
    StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
      return SignUpFormNotifier();
    });

class SignUpFormState {
  const SignUpFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.displayName = '',
    this.isLoading = false,
    this.acceptedTerms = false,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String displayName;
  final bool isLoading;
  final bool acceptedTerms;

  SignUpFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? displayName,
    bool? isLoading,
    bool? acceptedTerms,
  }) {
    return SignUpFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    );
  }

  bool get isValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword == password &&
        acceptedTerms;
  }
}

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  SignUpFormNotifier() : super(const SignUpFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void updateDisplayName(String displayName) {
    state = state.copyWith(displayName: displayName);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setAcceptedTerms(bool acceptedTerms) {
    state = state.copyWith(acceptedTerms: acceptedTerms);
  }

  void reset() {
    state = const SignUpFormState();
  }
}

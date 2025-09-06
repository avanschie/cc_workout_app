import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/auth_providers.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../widgets/form_components.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/config/env_config.dart';

/// Sign in screen with email/password authentication
///
/// Features:
/// - Email and password form with real-time validation
/// - Loading states during authentication
/// - Error handling with user-friendly messages
/// - Navigation to sign up and forgot password screens
/// - Environment-specific auto-login indicator
/// - Proper keyboard navigation and accessibility
/// - Material 3 design with responsive layout
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenSize.height -
                  MediaQuery.of(context).padding.vertical -
                  48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top spacing
                SizedBox(height: isSmallScreen ? 20 : 40),

                // Header section
                _buildHeader(theme, colorScheme),

                SizedBox(height: isSmallScreen ? 32 : 48),

                // Form section
                _buildForm(theme),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(theme),

                const SizedBox(height: 24),

                // Navigation options
                _buildNavigationOptions(theme),

                // Environment info
                if (_shouldShowEnvironmentInfo()) ...[
                  const SizedBox(height: 24),
                  _buildEnvironmentInfo(theme, colorScheme),
                ],

                // Bottom spacing
                SizedBox(height: isSmallScreen ? 20 : 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.fitness_center,
            size: 32,
            color: colorScheme.onPrimary,
          ),
        ),

        const SizedBox(height: 16),

        // Welcome text
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to track your powerlifting progress',
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
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),

          const SizedBox(height: 16),

          // Password field
          AuthPasswordField(
            controller: _passwordController,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sign In Button
        AuthSubmitButton(
          onPressed: _handleSignIn,
          text: 'Sign In',
          isLoading: _isLoading,
          isEnabled: !_isLoading,
          icon: Icons.login,
        ),

        const SizedBox(height: 12),

        // Forgot Password Link
        AuthTextButton(
          onPressed: _isLoading ? null : _handleForgotPassword,
          text: 'Forgot your password?',
          isEnabled: !_isLoading,
        ),
      ],
    );
  }

  Widget _buildNavigationOptions(ThemeData theme) {
    return Column(
      children: [
        // Divider with "or" text
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // Sign Up Button
        AuthSecondaryButton(
          onPressed: _isLoading ? null : _handleSignUp,
          text: 'Create new account',
          isEnabled: !_isLoading,
          icon: Icons.person_add,
        ),
      ],
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
        environmentText = config.enableAutoSignIn
            ? 'Local Dev (Auto-login enabled)'
            : 'Local Development';
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
          Text(
            environmentText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: environmentColor,
              fontWeight: FontWeight.w500,
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

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider);
      await authController.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Success handled by auth state listener
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Successfully signed in!');
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

  void _handleForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  void _handleSignUp() {
    Navigator.of(context).pushNamed('/sign-up');
  }

  String _getAuthErrorMessage(AuthException exception) {
    if (exception is InvalidCredentialsException) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (exception is UserNotFoundException) {
      return 'No account found with this email address.';
    } else if (exception is TooManyRequestsException) {
      return 'Too many failed attempts. Please try again later.';
    } else if (exception is NetworkAuthException) {
      return 'Network error. Please check your connection and try again.';
    } else if (exception is ServiceUnavailableException) {
      return 'Server error. Please try again in a few moments.';
    } else {
      return 'Sign in failed. Please try again.';
    }
  }
}

/// Provider for managing sign in form state (if needed for more complex state management)
final signInFormProvider =
    StateNotifierProvider<SignInFormNotifier, SignInFormState>((ref) {
      return SignInFormNotifier();
    });

class SignInFormState {
  const SignInFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.showPassword = false,
  });

  final String email;
  final String password;
  final bool isLoading;
  final bool showPassword;

  SignInFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? showPassword,
  }) {
    return SignInFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      showPassword: showPassword ?? this.showPassword,
    );
  }
}

class SignInFormNotifier extends StateNotifier<SignInFormState> {
  SignInFormNotifier() : super(const SignInFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void reset() {
    state = const SignInFormState();
  }
}

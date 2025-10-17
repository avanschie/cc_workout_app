import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/presentation/widgets/form_components.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';
import 'package:cc_workout_app/core/config/env_config.dart';

/// Forgot password screen for requesting password reset emails
///
/// Features:
/// - Simple email input form with validation
/// - Loading state during password reset request
/// - Success and error handling with user feedback
/// - Clear instructions and help text
/// - Back navigation to sign in screen
/// - Environment-specific messaging
/// - Resend functionality with cooldown
/// - Accessibility support with proper labels and hints
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _emailSent = false;
  DateTime? _lastSentTime;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          tooltip: 'Back to sign in',
        ),
        title: Text(
          'Reset Password',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Header section
              _buildHeader(theme, colorScheme),

              const SizedBox(height: 48),

              // Content based on state
              if (_emailSent)
                _buildSuccessContent(theme, colorScheme)
              else
                _buildFormContent(theme),

              const SizedBox(height: 32),

              // Environment info
              if (_shouldShowEnvironmentInfo()) ...[
                _buildEnvironmentInfo(theme, colorScheme),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 32,
            color: colorScheme.onPrimaryContainer,
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          _emailSent ? 'Check Your Email' : 'Forgot Your Password?',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          _emailSent
              ? 'We\'ve sent a password reset link to your email address'
              : 'No worries! Enter your email address and we\'ll send you a reset link',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Form
        Form(
          key: _formKey,
          child: AuthEmailField(
            controller: _emailController,
            enabled: !_isLoading,
            autofocus: true,
            labelText: 'Email Address',
            hintText: 'Enter the email for your account',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _handleSendResetEmail,
          ),
        ),

        const SizedBox(height: 32),

        // Send button
        AuthSubmitButton(
          key: const Key('reset_password_button'),
          onPressed: _handleSendResetEmail,
          text: 'Send Reset Link',
          isLoading: _isLoading,
          isEnabled: !_isLoading,
          icon: Icons.send,
        ),

        const SizedBox(height: 16),

        // Help text
        _buildHelpText(theme),
      ],
    );
  }

  Widget _buildSuccessContent(ThemeData theme, ColorScheme colorScheme) {
    final canResend = _canResendEmail();
    final remainingCooldown = _getRemainingCooldownSeconds();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email address display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _emailController.text.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Instructions
        _buildInstructionsList(theme, colorScheme),

        const SizedBox(height: 32),

        // Resend button
        AuthSecondaryButton(
          onPressed: canResend ? _handleResendEmail : null,
          text: canResend ? 'Resend Email' : 'Resend in ${remainingCooldown}s',
          isEnabled: canResend,
          icon: Icons.refresh,
        ),

        const SizedBox(height: 16),

        // Back to sign in
        AuthTextButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Back to Sign In',
        ),
      ],
    );
  }

  Widget _buildInstructionsList(ThemeData theme, ColorScheme colorScheme) {
    const instructions = [
      'Check your email inbox (and spam folder)',
      'Click the reset link in the email',
      'Create a new password',
      'Sign in with your new password',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next steps:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...instructions.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final instruction = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHelpText(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Having trouble?',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure you enter the email address associated with your account. '
            'The reset link will expire in 24 hours for security.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentInfo(ThemeData theme, ColorScheme colorScheme) {
    final environment = EnvConfig.environment;

    String environmentText;
    IconData environmentIcon;
    Color environmentColor;

    switch (environment) {
      case Environment.local:
        environmentText = 'Local Dev - Emails may not be delivered';
        environmentIcon = Icons.developer_mode;
        environmentColor = Colors.orange;
        break;
      case Environment.staging:
        environmentText = 'Staging Environment - Test emails only';
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
        children: [
          Icon(environmentIcon, size: 16, color: environmentColor),
          const SizedBox(width: 8),
          Expanded(
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

  bool _canResendEmail() {
    if (_lastSentTime == null) {
      return false;
    }
    final now = DateTime.now();
    const cooldownDuration = Duration(seconds: 60); // 1 minute cooldown
    return now.difference(_lastSentTime!) >= cooldownDuration;
  }

  int _getRemainingCooldownSeconds() {
    if (_lastSentTime == null) {
      return 0;
    }
    final now = DateTime.now();
    const cooldownDuration = Duration(seconds: 60);
    final elapsed = now.difference(_lastSentTime!);
    final remaining = cooldownDuration - elapsed;
    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider);
      await authController.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
          _lastSentTime = DateTime.now();
        });

        SnackBarUtils.showSuccess(
          context,
          'Password reset email sent successfully!',
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, _getAuthErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to send reset email. Please try again.',
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

  Future<void> _handleResendEmail() async {
    if (!_canResendEmail()) {
      return;
    }

    await _handleSendResetEmail();
  }

  String _getAuthErrorMessage(AuthException exception) {
    if (exception is UserNotFoundException) {
      return 'No account found with this email address.';
    } else if (exception is InvalidEmailException) {
      return 'Please enter a valid email address.';
    } else if (exception is TooManyRequestsException) {
      return 'Too many requests. Please try again later.';
    } else if (exception is NetworkAuthException) {
      return 'Network error. Please check your connection and try again.';
    } else if (exception is ServiceUnavailableException) {
      return 'Server error. Please try again in a few moments.';
    } else {
      return 'Failed to send reset email. Please try again.';
    }
  }
}

/// Timer provider for managing resend cooldown (if needed for more complex state management)
final forgotPasswordTimerProvider =
    StateNotifierProvider<ForgotPasswordTimerNotifier, int>((ref) {
      return ForgotPasswordTimerNotifier();
    });

class ForgotPasswordTimerNotifier extends StateNotifier<int> {
  ForgotPasswordTimerNotifier() : super(0);

  void startCooldown() {
    state = 60; // 60 seconds cooldown
    _countdown();
  }

  void _countdown() {
    if (state > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && state > 0) {
          state = state - 1;
          _countdown();
        }
      });
    }
  }

  void reset() {
    state = 0;
  }
}

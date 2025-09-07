import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Email validation result
enum EmailValidationResult { valid, empty, invalid }

/// Password validation result
enum PasswordValidationResult { valid, empty, tooShort, tooWeak }

/// Utility class for form validation
class AuthFormValidation {
  AuthFormValidation._();

  static const int minPasswordLength = 8;

  /// Email validation regex pattern
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+([.-]?[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  static EmailValidationResult validateEmail(String email) {
    if (email.trim().isEmpty) {
      return EmailValidationResult.empty;
    }
    if (!_emailPattern.hasMatch(email.trim())) {
      return EmailValidationResult.invalid;
    }
    return EmailValidationResult.valid;
  }

  /// Validates password strength
  static PasswordValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return PasswordValidationResult.empty;
    }
    if (password.length < minPasswordLength) {
      return PasswordValidationResult.tooShort;
    }
    // Basic password strength check
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) {
      return PasswordValidationResult.tooWeak;
    }
    return PasswordValidationResult.valid;
  }

  /// Gets error message for email validation result
  static String? getEmailErrorMessage(EmailValidationResult result) {
    switch (result) {
      case EmailValidationResult.empty:
        return 'Email is required';
      case EmailValidationResult.invalid:
        return 'Please enter a valid email address';
      case EmailValidationResult.valid:
        return null;
    }
  }

  /// Gets error message for password validation result
  static String? getPasswordErrorMessage(PasswordValidationResult result) {
    switch (result) {
      case PasswordValidationResult.empty:
        return 'Password is required';
      case PasswordValidationResult.tooShort:
        return 'Password must be at least $minPasswordLength characters';
      case PasswordValidationResult.tooWeak:
        return 'Password must contain both letters and numbers';
      case PasswordValidationResult.valid:
        return null;
    }
  }
}

/// Reusable email input field with validation
class AuthEmailField extends StatefulWidget {
  const AuthEmailField({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.labelText = 'Email',
    this.hintText = 'Enter your email address',
    this.validator,
    this.showValidationIcon = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool showValidationIcon;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;

  @override
  State<AuthEmailField> createState() => _AuthEmailFieldState();
}

class _AuthEmailFieldState extends State<AuthEmailField> {
  late TextEditingController _controller;
  bool _hasUserInput = false;
  EmailValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _hasUserInput = text.isNotEmpty;
      _validationResult = _hasUserInput
          ? AuthFormValidation.validateEmail(text)
          : null;
    });
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? suffixIcon;
    if (widget.showValidationIcon &&
        _hasUserInput &&
        _validationResult != null) {
      switch (_validationResult!) {
        case EmailValidationResult.valid:
          suffixIcon = Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
            size: 20,
          );
          break;
        case EmailValidationResult.empty:
        case EmailValidationResult.invalid:
          suffixIcon = Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 20,
          );
          break;
      }
    }

    return TextFormField(
      key: const Key('email_field'),
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator:
          widget.validator ??
          (value) {
            final result = AuthFormValidation.validateEmail(value ?? '');
            return AuthFormValidation.getEmailErrorMessage(result);
          },
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
    );
  }
}

/// Reusable password input field with validation
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.showValidationIcon = true,
    this.showStrengthIndicator = false,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.isConfirmationField = false,
    this.originalPasswordController,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool showValidationIcon;
  final bool showStrengthIndicator;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;
  final bool isConfirmationField;
  final TextEditingController? originalPasswordController;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  late TextEditingController _controller;
  bool _obscureText = true;
  bool _hasUserInput = false;
  PasswordValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _hasUserInput = text.isNotEmpty;
      _validationResult = _hasUserInput && !widget.isConfirmationField
          ? AuthFormValidation.validatePassword(text)
          : null;
    });
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? suffixIcon;
    if (widget.showValidationIcon &&
        _hasUserInput &&
        _validationResult != null) {
      switch (_validationResult!) {
        case PasswordValidationResult.valid:
          suffixIcon = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              _buildVisibilityToggle(colorScheme),
            ],
          );
          break;
        case PasswordValidationResult.empty:
        case PasswordValidationResult.tooShort:
        case PasswordValidationResult.tooWeak:
          suffixIcon = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 20),
              const SizedBox(width: 8),
              _buildVisibilityToggle(colorScheme),
            ],
          );
          break;
      }
    } else {
      suffixIcon = _buildVisibilityToggle(colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: Key(
            widget.isConfirmationField
                ? 'confirm_password_field'
                : 'password_field',
          ),
          controller: _controller,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator:
              widget.validator ??
              (value) {
                if (widget.isConfirmationField) {
                  final originalPassword =
                      widget.originalPasswordController?.text ?? '';
                  if (value != originalPassword) {
                    return 'Passwords do not match';
                  }
                  return null;
                }
                final result = AuthFormValidation.validatePassword(value ?? '');
                return AuthFormValidation.getPasswordErrorMessage(result);
              },
          onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
        ),
        if (widget.showStrengthIndicator &&
            _hasUserInput &&
            !widget.isConfirmationField)
          _buildPasswordStrengthIndicator(theme, colorScheme),
      ],
    );
  }

  Widget _buildVisibilityToggle(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility : Icons.visibility_off,
        color: colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      tooltip: _obscureText ? 'Show password' : 'Hide password',
    );
  }

  Widget _buildPasswordStrengthIndicator(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_validationResult == null) return const SizedBox.shrink();

    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (_validationResult!) {
      case PasswordValidationResult.empty:
        return const SizedBox.shrink();
      case PasswordValidationResult.tooShort:
        strengthColor = colorScheme.error;
        strengthText = 'Too short';
        strengthValue = 0.2;
        break;
      case PasswordValidationResult.tooWeak:
        strengthColor = Colors.orange;
        strengthText = 'Weak';
        strengthValue = 0.5;
        break;
      case PasswordValidationResult.valid:
        strengthColor = colorScheme.primary;
        strengthText = 'Good';
        strengthValue = 0.8;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: strengthValue,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            'Password strength: $strengthText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: strengthColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable display name input field
class AuthDisplayNameField extends StatefulWidget {
  const AuthDisplayNameField({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.labelText = 'Display Name (Optional)',
    this.hintText = 'Enter your display name',
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onFieldSubmitted;

  @override
  State<AuthDisplayNameField> createState() => _AuthDisplayNameFieldState();
}

class _AuthDisplayNameFieldState extends State<AuthDisplayNameField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('display_name_field'),
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50), // Reasonable name length limit
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
    );
  }
}

/// Submit button for auth forms with loading state
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : icon != null
            ? Icon(icon)
            : const SizedBox.shrink(),
        label: Text(
          isLoading ? 'Loading...' : text,
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
  }
}

/// Secondary button for auth forms (e.g., "Don't have an account?")
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled = true,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isEnabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
      ),
    );
  }
}

/// Text button for auth forms (e.g., "Forgot Password?")
class AuthTextButton extends StatelessWidget {
  const AuthTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      child: Text(text),
    );
  }
}

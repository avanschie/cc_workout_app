/// Base class for all authentication-related exceptions in the domain layer.
abstract class AuthException implements Exception {
  const AuthException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when authentication credentials are invalid.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? code])
    : super('Invalid email or password', code);
}

/// Exception thrown when a user is not found.
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? code]) : super('User not found', code);
}

/// Exception thrown when a user already exists.
class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException([String? code])
    : super('User already exists with this email', code);
}

/// Exception thrown when email verification is required.
class EmailNotConfirmedException extends AuthException {
  const EmailNotConfirmedException([String? code])
    : super('Email confirmation required', code);
}

/// Exception thrown when password is too weak.
class WeakPasswordException extends AuthException {
  const WeakPasswordException([String? code])
    : super('Password is too weak', code);
}

/// Exception thrown when email format is invalid.
class InvalidEmailException extends AuthException {
  const InvalidEmailException([String? code])
    : super('Invalid email format', code);
}

/// Exception thrown when rate limit is exceeded.
class TooManyRequestsException extends AuthException {
  const TooManyRequestsException([String? code])
    : super('Too many requests. Please try again later', code);
}

/// Exception thrown when the authentication service is unavailable.
class ServiceUnavailableException extends AuthException {
  const ServiceUnavailableException([String? code])
    : super('Authentication service is currently unavailable', code);
}

/// Exception thrown when session is expired or invalid.
class InvalidSessionException extends AuthException {
  const InvalidSessionException([String? code])
    : super('Session expired or invalid', code);
}

/// Exception thrown for network-related authentication errors.
class NetworkAuthException extends AuthException {
  const NetworkAuthException([String? code])
    : super('Network error during authentication', code);
}

/// Exception thrown for unknown authentication errors.
class UnknownAuthException extends AuthException {
  const UnknownAuthException(super.message, [super.code]);
}

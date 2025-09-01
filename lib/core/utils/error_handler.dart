import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

enum AppErrorType { network, authentication, validation, database, unknown }

class AppError {
  final String message;
  final AppErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  factory AppError.fromException(dynamic error, [StackTrace? stackTrace]) {
    if (error is PostgrestException) {
      return AppError(
        message: _getPostgrestErrorMessage(error),
        type: AppErrorType.database,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AuthException) {
      return AppError(
        message: _getAuthErrorMessage(error),
        type: AppErrorType.authentication,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is SocketException || error is HttpException) {
      return AppError(
        message:
            'Network connection error. Please check your internet connection.',
        type: AppErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return AppError(
        message: 'Invalid data format received.',
        type: AppErrorType.validation,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppError(
      message: 'An unexpected error occurred. Please try again.',
      type: AppErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static String _getPostgrestErrorMessage(PostgrestException error) {
    switch (error.code) {
      case '23505':
        return 'This entry already exists. Please check your data.';
      case '23503':
        return 'Invalid reference in data. Please check your input.';
      case '42601':
        return 'Invalid data format. Please check your input.';
      case 'PGRST301':
        return 'You do not have permission to perform this action.';
      default:
        if (error.message.toLowerCase().contains('network')) {
          return 'Network error occurred. Please check your connection.';
        }
        return 'Database error: ${error.message}';
    }
  }

  static String _getAuthErrorMessage(AuthException error) {
    switch (error.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Invalid email or password. Please try again.';
      case 'email not confirmed':
        return 'Please check your email and click the confirmation link.';
      case 'too many requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Authentication error: ${error.message}';
    }
  }

  void logError() {
    if (kDebugMode) {
      debugPrint('AppError: $type - $message');
      if (originalError != null) {
        debugPrint('Original error: $originalError');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    final appError = AppError.fromException(error, stackTrace);
    appError.logError();
    return appError;
  }

  static bool isNetworkError(AppError error) {
    return error.type == AppErrorType.network;
  }

  static bool isRetryableError(AppError error) {
    return error.type == AppErrorType.network ||
        (error.type == AppErrorType.database &&
            error.originalError is PostgrestException &&
            _isRetryablePostgrestError(
              error.originalError as PostgrestException,
            ));
  }

  static bool _isRetryablePostgrestError(PostgrestException error) {
    // Retry on timeout, connection issues, or server errors
    return error.code == 'PGRST000' || // Generic server error
        error.code == 'PGRST001' || // Connection error
        error.message.toLowerCase().contains('timeout') ||
        error.message.toLowerCase().contains('connection');
  }
}

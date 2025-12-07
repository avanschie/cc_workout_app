import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Service for handling retry logic with exponential backoff
class RetryService {
  static const int _defaultMaxRetries = 3;
  static const Duration _defaultInitialDelay = Duration(milliseconds: 500);
  static const double _defaultBackoffMultiplier = 2.0;

  /// Executes a function with retry logic and exponential backoff
  ///
  /// [operation] - The async operation to retry
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  /// [initialDelay] - Initial delay before first retry (default: 500ms)
  /// [backoffMultiplier] - Multiplier for exponential backoff (default: 2.0)
  /// [retryIf] - Optional predicate to determine if error should trigger retry
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = _defaultMaxRetries,
    Duration initialDelay = _defaultInitialDelay,
    double backoffMultiplier = _defaultBackoffMultiplier,
    bool Function(dynamic error)? retryIf,
  }) async {
    int attempts = 0;
    late dynamic lastError;

    while (attempts <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempts++;

        // Check if we should retry this error
        final shouldRetry =
            retryIf?.call(error) ?? _shouldRetryByDefault(error);

        if (attempts > maxRetries || !shouldRetry) {
          if (kDebugMode) {
            debugPrint(
              'RetryService: Max retries ($maxRetries) exceeded or error not retryable. Final error: $error',
            );
          }
          rethrow;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(
          attempts,
          initialDelay,
          backoffMultiplier,
        );

        if (kDebugMode) {
          debugPrint(
            'RetryService: Attempt $attempts failed, retrying in ${delay.inMilliseconds}ms. Error: $error',
          );
        }

        await Future.delayed(delay);
      }
    }

    throw lastError;
  }

  /// Calculate delay with exponential backoff and jitter
  static Duration _calculateDelay(
    int attempt,
    Duration initialDelay,
    double backoffMultiplier,
  ) {
    final exponentialDelay =
        initialDelay.inMilliseconds * pow(backoffMultiplier, attempt - 1);

    // Add jitter (random variation) to prevent thundering herd
    final jitter = Random().nextDouble() * 0.1; // 0-10% jitter
    final delayWithJitter = exponentialDelay * (1 + jitter);

    return Duration(milliseconds: delayWithJitter.round());
  }

  /// Default retry predicate - determines which errors should trigger retry
  static bool _shouldRetryByDefault(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // Network-related errors that are typically transient
    return errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('dns') ||
        errorMessage.contains('server') ||
        errorMessage.contains('500') ||
        errorMessage.contains('502') ||
        errorMessage.contains('503') ||
        errorMessage.contains('504');
  }

  /// Predicate for database/Supabase specific errors
  static bool shouldRetryDatabaseError(dynamic error) {
    if (!_shouldRetryByDefault(error)) {
      return false;
    }

    final errorMessage = error.toString().toLowerCase();

    // Don't retry authentication or permission errors
    if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden') ||
        errorMessage.contains('invalid login') ||
        errorMessage.contains('permission denied')) {
      return false;
    }

    return true;
  }

  /// Predicate for API/network specific errors
  static bool shouldRetryNetworkError(dynamic error) {
    return _shouldRetryByDefault(error);
  }
}

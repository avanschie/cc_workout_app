import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cc_workout_app/core/utils/error_handler.dart';

class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });
}

class RetryUtils {
  static const defaultConfig = RetryConfig();

  static Future<T> retry<T>(
    Future<T> Function() operation, {
    RetryConfig config = defaultConfig,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var currentDelay = config.initialDelay;

    for (int attempt = 0; attempt < config.maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        final appError = ErrorHandler.handleError(error, stackTrace);

        final isLastAttempt = attempt == config.maxRetries - 1;
        final shouldRetryError =
            shouldRetry?.call(error) ?? ErrorHandler.isRetryableError(appError);

        if (isLastAttempt || !shouldRetryError) {
          rethrow;
        }

        if (kDebugMode) {
          debugPrint(
            'Retry attempt ${attempt + 1}/${config.maxRetries} failed: $appError',
          );
          debugPrint(
            'Waiting ${currentDelay.inMilliseconds}ms before retry...',
          );
        }

        await Future.delayed(currentDelay);

        // Exponential backoff with jitter
        final nextDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * config.backoffMultiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );

        // Add some jitter (±25% of delay)
        final jitterMs =
            (nextDelay.inMilliseconds * 0.25 * (Random().nextDouble() - 0.5))
                .round();
        currentDelay = Duration(
          milliseconds: nextDelay.inMilliseconds + jitterMs,
        );
      }
    }

    throw StateError('This should never be reached');
  }

  static Future<T> retryWithProgressCallback<T>(
    Future<T> Function() operation, {
    RetryConfig config = defaultConfig,
    void Function(int attempt, int maxRetries)? onRetry,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var currentDelay = config.initialDelay;

    for (int attempt = 0; attempt < config.maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        final appError = ErrorHandler.handleError(error, stackTrace);

        final isLastAttempt = attempt == config.maxRetries - 1;
        final shouldRetryError =
            shouldRetry?.call(error) ?? ErrorHandler.isRetryableError(appError);

        if (isLastAttempt || !shouldRetryError) {
          rethrow;
        }

        onRetry?.call(attempt + 1, config.maxRetries);

        await Future.delayed(currentDelay);

        // Exponential backoff with jitter
        final nextDelay = Duration(
          milliseconds: min(
            (currentDelay.inMilliseconds * config.backoffMultiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );

        // Add some jitter (±25% of delay)
        final jitterMs =
            (nextDelay.inMilliseconds * 0.25 * (Random().nextDouble() - 0.5))
                .round();
        currentDelay = Duration(
          milliseconds: nextDelay.inMilliseconds + jitterMs,
        );
      }
    }

    throw StateError('This should never be reached');
  }
}

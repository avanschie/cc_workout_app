import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('should report as not configured when not initialized', () {
      // Reset the config to ensure clean state
      expect(EnvConfig.isConfigured, isFalse);
    });

    test(
      'should throw exception when accessing config before initialization',
      () {
        expect(() => EnvConfig.supabaseUrl, throwsA(isA<Exception>()));
        expect(() => EnvConfig.supabaseAnonKey, throwsA(isA<Exception>()));
        expect(() => EnvConfig.config, throwsA(isA<Exception>()));
        expect(() => EnvConfig.environment, throwsA(isA<Exception>()));
      },
    );

    test('should throw exception when validating uninitialized config', () {
      expect(() => EnvConfig.validateConfig(), throwsA(isA<Exception>()));
    });

    test('should work correctly when initialized with local config', () {
      EnvConfig.initialize(Environment.local, EnvironmentConfig.local);

      expect(EnvConfig.isConfigured, isTrue);
      expect(EnvConfig.environment, equals(Environment.local));
      expect(EnvConfig.supabaseUrl, equals('http://10.0.2.2:54321'));
      expect(EnvConfig.supabaseAnonKey, isNotEmpty);
      expect(EnvConfig.config.enableLogging, isTrue);
      expect(EnvConfig.config.enableAutoSignIn, isTrue);
      expect(EnvConfig.config.requireEmailVerification, isFalse);

      // Should not throw when validating initialized config
      expect(() => EnvConfig.validateConfig(), returnsNormally);
    });

    test('should create staging config with environment variables', () {
      // This test documents the behavior but cannot be run without actual env vars
      expect(() => EnvConfig.createStagingConfig(), throwsA(isA<Exception>()));
    });

    test('should create production config with environment variables', () {
      // This test documents the behavior but cannot be run without actual env vars
      expect(
        () => EnvConfig.createProductionConfig(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

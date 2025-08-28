import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('should have empty values when no environment variables are set', () {
      expect(EnvConfig.supabaseUrl, isEmpty);
      expect(EnvConfig.supabaseAnonKey, isEmpty);
    });

    test('should report as not configured when values are empty', () {
      expect(EnvConfig.isConfigured, isFalse);
    });

    test('should throw exception when validating empty config', () {
      expect(() => EnvConfig.validateConfig(), throwsA(isA<Exception>()));
    });
  });
}

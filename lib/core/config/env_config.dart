enum Environment { local, staging, production }

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.name,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.enableLogging,
    this.requireEmailVerification = true,
    this.enableAutoSignIn = false,
    this.sessionTimeoutMinutes = 60,
  });

  final String name;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableLogging;

  // Auth-specific settings
  final bool requireEmailVerification;
  final bool enableAutoSignIn;
  final int sessionTimeoutMinutes;

  static const local = EnvironmentConfig(
    name: 'Local',
    supabaseUrl: 'http://10.0.2.2:54321',
    supabaseAnonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    enableLogging: true,
    requireEmailVerification: false, // Skip email verification for local dev
    enableAutoSignIn: true, // Allow auto sign-in for local dev
    sessionTimeoutMinutes: 120, // Longer sessions for local dev
  );

  static EnvironmentConfig staging({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) => EnvironmentConfig(
    name: 'Staging',
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
    enableLogging: true,
    // Required for tests - disable in Supabase dashboard if needed
  );

  static EnvironmentConfig production({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) => EnvironmentConfig(
    name: 'Production',
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
    enableLogging: false,
    // Always require email verification in production
    sessionTimeoutMinutes: 30, // Shorter sessions for production security
  );
}

class EnvConfig {
  static EnvironmentConfig? _currentConfig;
  static Environment? _environment;

  static void initialize(Environment environment, EnvironmentConfig config) {
    _environment = environment;
    _currentConfig = config;
  }

  static Environment get environment {
    if (_environment == null) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }
    return _environment!;
  }

  static EnvironmentConfig get config {
    if (_currentConfig == null) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }
    return _currentConfig!;
  }

  // Backward compatibility getters
  static String get supabaseUrl => config.supabaseUrl;
  static String get supabaseAnonKey => config.supabaseAnonKey;
  static bool get isConfigured => _currentConfig != null;

  // Factory methods for different environments
  static EnvironmentConfig createStagingConfig() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || key.isEmpty) {
      throw Exception(
        'Staging environment requires SUPABASE_URL and SUPABASE_ANON_KEY '
        'via --dart-define. Use VSCode "Staging" configuration or run:\n'
        'flutter run -t lib/main_staging.dart --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key',
      );
    }

    return EnvironmentConfig.staging(supabaseUrl: url, supabaseAnonKey: key);
  }

  static EnvironmentConfig createProductionConfig() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || key.isEmpty) {
      throw Exception(
        'Production environment requires SUPABASE_URL and SUPABASE_ANON_KEY '
        'via --dart-define',
      );
    }

    return EnvironmentConfig.production(supabaseUrl: url, supabaseAnonKey: key);
  }

  static void validateConfig() {
    if (!isConfigured) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }
  }
}

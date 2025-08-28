class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static void validateConfig() {
    if (!isConfigured) {
      throw Exception(
        'Missing Supabase configuration. '
        'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define',
      );
    }
  }
}

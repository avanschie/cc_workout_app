# Environment Configuration

This directory contains configuration utilities for managing environment variables in the Flutter app.

## Usage

### Running with Environment Variables

To run the app with Supabase credentials:

```bash
flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Building with Environment Variables

For releases:

```bash
flutter build apk --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### In Code

```dart
import 'package:cc_workout_app/core/config/env_config.dart';

// Access configuration values
final url = EnvConfig.supabaseUrl;
final key = EnvConfig.supabaseAnonKey;

// Validate configuration is complete
EnvConfig.validateConfig(); // Throws if missing values

// Check if configured
if (EnvConfig.isConfigured) {
  // Initialize Supabase
}
```

## Security Note

Never commit actual Supabase credentials to version control. Use environment variables for all sensitive configuration data.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/core/navigation/app_router.dart';
import 'package:cc_workout_app/shared/widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if we have environment configuration, otherwise create production config
  if (!EnvConfig.isConfigured) {
    try {
      // Try to create production config from environment variables
      final productionConfig = EnvConfig.createProductionConfig();
      EnvConfig.initialize(Environment.production, productionConfig);
    } catch (e) {
      // Fallback to local configuration for development
      debugPrint('Production config not available, using local config: $e');
      EnvConfig.initialize(Environment.local, EnvironmentConfig.local);
    }
  }

  debugPrint('Environment: ${EnvConfig.config.name}');
  debugPrint('Supabase URL: ${EnvConfig.config.supabaseUrl}');

  await Supabase.initialize(
    url: EnvConfig.config.supabaseUrl,
    anonKey: EnvConfig.config.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override the Supabase client provider with the initialized instance
        supabaseClientProvider.overrideWithValue(Supabase.instance.client),
        // Add auth repository provider overrides
        ...getAuthProviderOverrides(),
      ],
      child: const ErrorBoundary(child: MainApp()),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Powerlifting Rep Max Tracker',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}

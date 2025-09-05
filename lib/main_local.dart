import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';
import 'package:cc_workout_app/shared/widgets/network_status_banner.dart';
import 'package:cc_workout_app/shared/widgets/error_boundary.dart';
import 'package:cc_workout_app/shared/widgets/environment_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local environment configuration
  EnvConfig.initialize(Environment.local, EnvironmentConfig.local);

  debugPrint('Environment: ${EnvConfig.config.name}');
  debugPrint('Supabase URL: ${EnvConfig.config.supabaseUrl}');

  await Supabase.initialize(
    url: EnvConfig.config.supabaseUrl,
    anonKey: EnvConfig.config.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ErrorBoundary(child: MainApp())));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Rep Max Tracker (Local)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
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
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
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
      themeMode: ThemeMode.system,
      home: const EnvironmentBanner(
        child: NetworkStatusBanner(child: MainNavigationShell()),
      ),
    );
  }
}

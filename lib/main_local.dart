import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/auth_gate.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/forgot_password_screen.dart';
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Rep Max Tracker (Local)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
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
      home: const AuthGate(),
      routes: {
        '/sign-in': (context) => const EnvironmentBanner(
          child: NetworkStatusBanner(child: SignInScreen()),
        ),
        '/sign-up': (context) => const EnvironmentBanner(
          child: NetworkStatusBanner(child: SignUpScreen()),
        ),
        '/forgot-password': (context) => const EnvironmentBanner(
          child: NetworkStatusBanner(child: ForgotPasswordScreen()),
        ),
      },
    );
  }
}

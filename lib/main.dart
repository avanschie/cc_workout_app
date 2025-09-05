import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/shared/widgets/skeleton_widgets.dart';
import 'package:cc_workout_app/shared/widgets/network_status_banner.dart';
import 'package:cc_workout_app/shared/widgets/error_boundary.dart';
import 'package:cc_workout_app/shared/widgets/rep_max_table_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug: Check environment variables
  debugPrint('Supabase URL: ${EnvConfig.supabaseUrl}');
  debugPrint('Supabase configured: ${EnvConfig.isConfigured}');

  if (!EnvConfig.isConfigured) {
    debugPrint(
      'Warning: Supabase not configured via --dart-define. Using fallback values for local development.',
    );
  }

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl.isEmpty
        ? 'http://10.0.2.2:54321'
        : EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey.isEmpty
        ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
        : EnvConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ErrorBoundary(child: MainApp())));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Rep Max Tracker',
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
      home: const NetworkStatusBanner(child: HomeScreen()),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repMaxTableAsync = ref.watch(repMaxTableNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Powerlifting Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(repMaxTableNotifierProvider.notifier).refresh();
        },
        child: repMaxTableAsync.when(
          loading: () => const SkeletonRepMaxTable(),
          error: (error, stackTrace) => _buildErrorState(context, error, ref),
          data: (repMaxTable) => _buildMainContent(context, repMaxTable),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddLiftScreen()),
          );

          // Refresh rep maxes when returning from add lift screen
          if (result == true) {
            ref.read(repMaxTableNotifierProvider.notifier).refresh();
          }
        },
        tooltip: 'Add Lift',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load rep maxes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(repMaxTableNotifierProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    Map<LiftType, Map<int, RepMax>> repMaxTable,
  ) {
    return RepMaxTableWidget(repMaxTable: repMaxTable);
  }
}

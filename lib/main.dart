import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';

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

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Powerlifting Rep Max Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(context, error),
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

  Widget _buildErrorState(BuildContext context, Object error) {
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
    return _buildModernRepMaxTable(context, repMaxTable);
  }

  Widget _buildModernRepMaxTable(
    BuildContext context,
    Map<LiftType, Map<int, RepMax>> repMaxTable,
  ) {
    return Column(
      children: [
        // Header row with modern styling
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reps',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              ...LiftType.values.map(
                (liftType) => Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _getShortLiftName(liftType),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Data rows - using Expanded to fill remaining space
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: 10,
            itemBuilder: (context, index) {
              final reps = index + 1;
              return _buildModernRepMaxRow(context, reps, repMaxTable, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernRepMaxRow(
    BuildContext context,
    int reps,
    Map<LiftType, Map<int, RepMax>> repMaxTable,
    int index,
  ) {
    final hasAnyDataInRow = LiftType.values.any(
      (liftType) => repMaxTable[liftType]?[reps] != null,
    );

    return Container(
      width: double.infinity,
      height: 50, // Fixed height for consistent sizing
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: hasAnyDataInRow
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$reps',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasAnyDataInRow
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          ...LiftType.values.map((liftType) {
            final repMax = repMaxTable[liftType]?[reps];
            final hasData = repMax != null;

            return Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: hasData
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05)
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  border: hasData
                      ? Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        )
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    hasData ? '${_formatWeight(repMax.weightKg)} kg' : '—',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: hasData ? FontWeight.w700 : FontWeight.w400,
                      color: hasData
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatWeight(double weight) {
    // Always show up to 2 decimal places, but remove unnecessary trailing zeros
    String formatted = weight.toStringAsFixed(2);

    // Remove trailing zeros and decimal point if not needed
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }

  String _getShortLiftName(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return 'Squat';
      case LiftType.bench:
        return 'Bench';
      case LiftType.deadlift:
        return 'Deadlift';
    }
  }
}

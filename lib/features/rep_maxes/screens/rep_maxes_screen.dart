import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/shared/widgets/skeleton_widgets.dart';
import 'package:cc_workout_app/shared/widgets/rep_max_table_widget.dart';

class RepMaxesScreen extends ConsumerWidget {
  const RepMaxesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repMaxTableAsync = ref.watch(repMaxTableNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rep Maxes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(repMaxTableNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(repMaxTableNotifierProvider.notifier).refresh();
        },
        child: repMaxTableAsync.when(
          loading: () => const SkeletonRepMaxTable(),
          error: (error, stackTrace) => _buildErrorState(context, error, ref),
          data: (repMaxTable) => _buildRepMaxTable(context, repMaxTable),
        ),
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

  Widget _buildRepMaxTable(
    BuildContext context,
    Map<LiftType, Map<int, RepMax>> repMaxTable,
  ) {
    return RepMaxTableWidget(repMaxTable: repMaxTable);
  }
}

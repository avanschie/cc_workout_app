import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';

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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(context, error),
          data: (repMaxTable) => _buildRepMaxTable(context, repMaxTable),
        ),
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

  Widget _buildRepMaxTable(
    BuildContext context,
    Map<LiftType, Map<int, RepMax>> repMaxTable,
  ) {
    final hasAnyData = repMaxTable.values.any((table) => table.isNotEmpty);

    if (!hasAnyData) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Weight Per Rep Range',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal records for each rep count',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ...LiftType.values.map(
            (liftType) => Column(
              children: [
                _buildLiftTypeSection(
                  context,
                  liftType,
                  repMaxTable[liftType] ?? {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.fitness_center,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Rep Maxes Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging your lifts to see your rep maxes here!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiftTypeSection(
    BuildContext context,
    LiftType liftType,
    Map<int, RepMax> repMaxes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getLiftIcon(liftType),
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              liftType.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (repMaxes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No data yet - start logging ${liftType.displayName.toLowerCase()} lifts!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          _buildRepMaxGrid(context, repMaxes),
      ],
    );
  }

  Widget _buildRepMaxGrid(BuildContext context, Map<int, RepMax> repMaxes) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Reps',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Best Weight',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(10, (index) {
            final reps = index + 1;
            final repMax = repMaxes[reps];
            return _buildRepMaxRow(context, reps, repMax, index % 2 == 1);
          }),
        ],
      ),
    );
  }

  Widget _buildRepMaxRow(
    BuildContext context,
    int reps,
    RepMax? repMax,
    bool isEven,
  ) {
    final hasData = repMax != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isEven
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : null,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$reps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: hasData ? FontWeight.w500 : FontWeight.normal,
                color: hasData
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              hasData ? '${repMax.weightKg.toStringAsFixed(1)} kg' : '—',
              style: TextStyle(
                fontSize: 16,
                fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
                color: hasData
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLiftIcon(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return Icons.fitness_center;
      case LiftType.bench:
        return Icons.airline_seat_flat;
      case LiftType.deadlift:
        return Icons.accessibility_new;
    }
  }
}

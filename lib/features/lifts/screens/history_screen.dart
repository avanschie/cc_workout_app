import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/providers/history_providers.dart';
import 'package:cc_workout_app/features/lifts/screens/edit_lift_screen.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';
import 'package:cc_workout_app/shared/constants/lift_colors.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyListProvider);
    final historyController = ref.read(historyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lift History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(historyListProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: historyState.when(
        data: (entries) => entries.isEmpty
            ? const _EmptyHistoryView()
            : _HistoryListView(
                entries: entries,
                historyController: historyController,
              ),
        loading: () => const _LoadingHistoryView(),
        error: (error, stackTrace) => _ErrorHistoryView(
          error: error,
          onRetry: () => ref.read(historyListProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _HistoryListView extends ConsumerWidget {
  const _HistoryListView({
    required this.entries,
    required this.historyController,
  });

  final List<LiftEntry> entries;
  final HistoryController historyController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(historyListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: entries.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final entry = entries[index];

          return _LiftEntryRow(
            entry: entry,
            index: index,
            onTap: () => _handleEdit(context, entry),
            onDelete: () => _handleDelete(context, ref, entry),
          );
        },
      ),
    );
  }

  void _handleEdit(BuildContext context, LiftEntry entry) async {
    historyController.startEdit(entry);

    // Navigate to EditLiftScreen
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditLiftScreen(liftEntry: entry),
        settings: const RouteSettings(name: '/edit-lift'),
      ),
    );

    // If edit was successful (saved or deleted), no need to refresh as providers handle it
    if (result == true) {
      // The providers will automatically refresh the UI
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    LiftEntry entry,
  ) async {
    final confirmed = await _showDeleteConfirmationDialog(context, entry);
    if (!confirmed) {
      return;
    }

    try {
      await historyController.deleteEntry(entry);
      if (context.mounted) {
        SnackBarUtils.showSuccess(
          context,
          '${entry.lift.displayName} entry deleted successfully',
        );
      }
    } catch (error) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to delete entry: ${error.toString()}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _handleDelete(context, ref, entry),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    LiftEntry entry,
  ) async {
    final dateFormatter = DateFormat('MMM d, yyyy');

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Lift Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Are you sure you want to delete this lift entry?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _LiftBadge(liftType: entry.lift),
                          const SizedBox(width: 8),
                          Text(
                            entry.lift.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${entry.reps} reps @ ${entry.weightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(entry.performedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _LiftEntryRow extends StatelessWidget {
  const _LiftEntryRow({
    required this.entry,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final LiftEntry entry;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final theme = Theme.of(context);

    // Alternating row background for table-like appearance
    final backgroundColor = index.isEven
        ? Colors.transparent
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _LiftBadge(liftType: entry.lift),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.reps} reps @ ${entry.weightKg.toStringAsFixed(1)} kg',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatter.format(entry.performedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onTap();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiftBadge extends StatelessWidget {
  const _LiftBadge({required this.liftType});

  final LiftType liftType;

  @override
  Widget build(BuildContext context) {
    final abbreviation = LiftColors.getAbbreviation(liftType);
    final backgroundColor = LiftColors.getColor(liftType);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          abbreviation,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          semanticsLabel: '${liftType.displayName} badge',
        ),
      ),
    );
  }
}

class _LoadingHistoryView extends StatelessWidget {
  const _LoadingHistoryView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6, // Show 6 skeleton loaders
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        return _SkeletonLiftRow(index: index);
      },
    );
  }
}

class _SkeletonLiftRow extends StatefulWidget {
  const _SkeletonLiftRow({required this.index});

  final int index;

  @override
  State<_SkeletonLiftRow> createState() => _SkeletonLiftRowState();
}

class _SkeletonLiftRowState extends State<_SkeletonLiftRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Alternating row background for table-like appearance
    final backgroundColor = widget.index.isEven
        ? Colors.transparent
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: _animation.value,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 140,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 14,
                      width: 90,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: _animation.value,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Lift History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your workouts by adding your first lift entry.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navigate to add lift screen
                // TODO: Implement navigation when add lift screen is connected
                SnackBarUtils.showInfo(
                  context,
                  'Add Lift navigation will be implemented',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Lift'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorHistoryView extends StatelessWidget {
  const _ErrorHistoryView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There was a problem loading your lift history. Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.toString()}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

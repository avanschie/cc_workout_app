import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/features/rep_maxes/screens/rep_maxes_screen.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/features/lifts/screens/add_lift_screen.dart';
import 'package:cc_workout_app/features/lifts/screens/history_screen.dart';
import 'package:cc_workout_app/features/lifts/providers/history_providers.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';

/// Provider to track the current navigation tab index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation shell widget that provides bottom navigation with two tabs:
/// - Rep Maxes (tab 0)
/// - History (tab 1)
///
/// Features:
/// - Uses IndexedStack to preserve tab state when switching
/// - Provides FloatingActionButton accessible from both tabs
/// - Handles refresh by triggering appropriate providers when returning from AddLiftScreen
/// - Material 3 design with proper theming and animations
class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rep Max Tracker'),
        actions: [
          // User menu with sign out option
          PopupMenuButton<String>(
            tooltip: 'User menu',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser?.displayName ??
                              currentUser?.email ??
                              'User',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (currentUser?.displayName != null)
                          Text(
                            currentUser!.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          // Tab 0: Rep Maxes
          const RepMaxesScreen(),
          // Tab 1: History
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        elevation: 8,
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline),
            selectedIcon: Icon(Icons.timeline),
            label: 'Rep Maxes',
            tooltip: 'View your current rep maxes',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
            tooltip: 'View your lift history',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleAddLift(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Lift'),
        tooltip: 'Add a new lift entry',
        elevation: 6,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Handles user menu actions
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'profile':
        // Future: Navigate to profile screen
        SnackBarUtils.showInfo(context, 'Profile screen coming soon!');
        break;
      case 'sign_out':
        _handleSignOut(context, ref);
        break;
    }
  }

  /// Handles the sign out action with confirmation dialog
  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authController = ref.read(authControllerProvider);
        await authController.signOut();

        if (context.mounted) {
          SnackBarUtils.showSuccess(context, 'Signed out successfully');
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarUtils.showError(
            context,
            'Failed to sign out. Please try again.',
          );
        }
      }
    }
  }

  /// Handles the add lift action by navigating to AddLiftScreen
  /// and triggering refresh when a successful result is returned
  Future<void> _handleAddLift(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AddLiftScreen(),
        settings: const RouteSettings(name: '/add-lift'),
      ),
    );

    // If AddLiftScreen returns true (successful save), trigger refresh
    if (result == true) {
      // Refresh rep maxes data when returning from successful add lift
      ref.read(repMaxTableNotifierProvider.notifier).refresh();

      // Also refresh history data
      ref.read(historyListProvider.notifier).refresh();
    }
  }
}

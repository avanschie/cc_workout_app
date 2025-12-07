import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:cc_workout_app/core/navigation/app_routes.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';

/// Provider to track the current navigation tab index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation shell widget that provides the app structure with:
/// - App bar with user menu and sign out
/// - FloatingActionButton for adding lifts
/// - Proper GoRouter integration
///
/// This shell wraps the main content and provides consistent navigation elements
class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
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

  /// Build bottom navigation bar based on current route
  Widget _buildBottomNavigation(BuildContext context) {
    final state = GoRouterState.of(context);
    final currentLocation = state.fullPath ?? state.uri.toString();
    int selectedIndex = 0;

    // Determine selected index based on current route
    if (currentLocation == AppRoute.home.path ||
        currentLocation == AppRoute.repMaxes.path) {
      selectedIndex = 0;
    } else if (currentLocation == AppRoute.history.path) {
      selectedIndex = 1;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoute.repMaxes.path);
            break;
          case 1:
            context.go(AppRoute.history.path);
            break;
        }
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
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.signOut();

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

  /// Handles the add lift action by navigating to AddLiftScreen using GoRouter
  void _handleAddLift(BuildContext context, WidgetRef ref) {
    context.push(AppRoute.addLift.path);
  }
}

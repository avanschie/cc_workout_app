import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';

void main() {
  group('MainNavigationShell', () {
    setUp(() {
      // Initialize EnvConfig for tests
      if (!EnvConfig.isConfigured) {
        EnvConfig.initialize(Environment.local, EnvironmentConfig.local);
      }
    });

    testWidgets('MainNavigationShell displays app structure with GoRouter', (
      WidgetTester tester,
    ) async {
      // Create a mock authenticated user
      final testUser = AuthUser(
        id: 'test-user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      // Create a simple GoRouter for testing
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ProviderScope(
              overrides: [
                currentUserProvider.overrideWithValue(testUser),
              ],
              child: const MainNavigationShell(
                child: Scaffold(body: Center(child: Text('Test Content'))),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Test MainNavigationShell specific elements
      expect(find.text('Rep Max Tracker'), findsOneWidget); // Shows in app bar
      expect(find.text('Rep Maxes'), findsOneWidget); // Tab label in navigation
      expect(find.text('History'), findsOneWidget); // History tab in navigation
      expect(find.byType(FloatingActionButton), findsOneWidget); // FAB for adding lifts
      expect(find.text('Test Content'), findsOneWidget); // The child content
    });

    testWidgets('MainNavigationShell displays user info in menu', (
      WidgetTester tester,
    ) async {
      // Create a mock authenticated user
      final testUser = AuthUser(
        id: 'test-user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      // Create a simple GoRouter for testing
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ProviderScope(
              overrides: [
                currentUserProvider.overrideWithValue(testUser),
              ],
              child: const MainNavigationShell(
                child: Scaffold(body: Center(child: Text('Test Content'))),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the user menu button (CircleAvatar)
      final userMenuButton = find.byType(PopupMenuButton<String>);
      expect(userMenuButton, findsOneWidget);

      // Tap the user menu to open it
      await tester.tap(userMenuButton);
      await tester.pumpAndSettle();

      // Check that user info appears in the opened menu
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}

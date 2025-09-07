import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([RepMaxCalculationService])
void main() {
  group('MainNavigationShell', () {
    setUp(() {
      // Initialize EnvConfig for tests
      if (!EnvConfig.isConfigured) {
        EnvConfig.initialize(Environment.local, EnvironmentConfig.local);
      }
    });

    testWidgets('App displays main screen with empty state', (
      WidgetTester tester,
    ) async {
      final mockService = MockRepMaxCalculationService();
      final emptyRepMaxTable = {
        for (final liftType in LiftType.values) liftType: <int, RepMax>{},
      };

      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => emptyRepMaxTable);

      // Create a mock authenticated user
      final testUser = AuthUser(
        id: 'test-user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              repMaxCalculationServiceProvider.overrideWithValue(mockService),
              currentUserProvider.overrideWithValue(testUser),
            ],
            child: const MainNavigationShell(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rep Max Tracker'), findsOneWidget); // Shows in app bar
      expect(
        find.text('Rep Maxes'),
        findsAtLeast(1),
      ); // Tab label (may appear multiple times)
      expect(find.text('History'), findsOneWidget); // History tab in navigation

      // Should show table even with empty data
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(
        find.text('—'),
        findsWidgets,
      ); // Should show dashes for empty entries

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('App displays main screen with rep max data', (
      WidgetTester tester,
    ) async {
      final mockService = MockRepMaxCalculationService();
      final sampleRepMaxTable = {
        LiftType.squat: {
          1: RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 1,
            weightKg: 200.0,
            lastPerformedAt: DateTime(2023, 1, 1),
          ),
        },
        LiftType.bench: <int, RepMax>{},
        LiftType.deadlift: <int, RepMax>{},
      };

      when(
        mockService.getFullRepMaxTable(),
      ).thenAnswer((_) async => sampleRepMaxTable);

      // Create a mock authenticated user
      final testUser = AuthUser(
        id: 'test-user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              repMaxCalculationServiceProvider.overrideWithValue(mockService),
              currentUserProvider.overrideWithValue(testUser),
            ],
            child: const MainNavigationShell(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rep Max Tracker'), findsOneWidget); // Shows in app bar
      expect(
        find.text('Rep Maxes'),
        findsAtLeast(1),
      ); // Tab label (may appear multiple times)
      expect(find.text('History'), findsOneWidget); // History tab in navigation
      expect(find.text('200 kg'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

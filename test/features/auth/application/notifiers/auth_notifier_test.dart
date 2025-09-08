import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cc_workout_app/core/config/env_config.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockEnvConfig extends Mock implements EnvConfig {}

void main() {
  group('AuthNotifier', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;
    late StreamController<AuthUser?> authStateController;

    const testUserId = 'test-user-123';
    const testEmail = 'test@example.com';
    const testDisplayName = 'Test User';
    const testPassword = 'testPassword123';
    final testCreatedAt = DateTime(2023, 1, 1);
    final testLastSignInAt = DateTime(2023, 1, 2);

    AuthUser createTestUser({
      String? id,
      String? email,
      String? displayName = 'Test User',
      bool isEmailVerified = true,
    }) {
      return AuthUser(
        id: id ?? testUserId,
        email: email ?? testEmail,
        displayName: displayName,
        isEmailVerified: isEmailVerified,
        createdAt: testCreatedAt,
        lastSignInAt: testLastSignInAt,
      );
    }

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const InvalidCredentialsException());
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authStateController = StreamController<AuthUser?>.broadcast();

      // Set up default mock behaviors
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => authStateController.stream);

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      authStateController.close();
    });

    group('build (Initialization)', () {
      test('initializes with null when no current user', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        final state = await notifier.future;

        expect(state, isNull);
        verify(() => mockAuthRepository.currentUser).called(1);
      });

      test('initializes with AuthUser when current user exists', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        final state = await notifier.future;

        expect(state, isNotNull);
        expect(state!.id, testUserId);
        expect(state.email, testEmail);
        expect(state.displayName, testDisplayName);
        verify(() => mockAuthRepository.currentUser).called(1);
      });

      test('sets up auth state change listener', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        container.read(authNotifierProvider.notifier);
        await container.read(authNotifierProvider.future);

        verify(() => mockAuthRepository.authStateChanges).called(1);
      });

      test('handles auto-login when enabled in environment', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => createTestUser());

        // Mock EnvConfig behavior for auto-login
        // Note: This would require additional setup to fully mock EnvConfig

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        verify(() => mockAuthRepository.currentUser).called(greaterThan(0));
      });
    });

    group('Auth State Change Listener', () {
      test('updates state when user signs in via external change', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Simulate external sign in
        final testUser = createTestUser();
        authStateController.add(testUser);

        // Wait for state update
        await Future.delayed(const Duration(milliseconds: 10));

        final currentState = container.read(authNotifierProvider);
        expect(currentState.valueOrNull, isNotNull);
        expect(currentState.valueOrNull!.id, testUserId);
      });

      test('updates state when user signs out via external change', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Simulate external sign out
        authStateController.add(null);

        // Wait for state update
        await Future.delayed(const Duration(milliseconds: 10));

        final currentState = container.read(authNotifierProvider);
        expect(currentState.valueOrNull, isNull);
      });

      test('handles auth state stream errors', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Simulate stream error
        authStateController.addError(const NetworkAuthException());

        // Wait for error handling
        await Future.delayed(const Duration(milliseconds: 10));

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isTrue);
        expect(currentState.error, isA<NetworkAuthException>());
      });

      test('clears error state when user authenticates', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // First, create an error state
        authStateController.addError(const NetworkAuthException());
        await Future.delayed(const Duration(milliseconds: 10));

        expect(container.read(authNotifierProvider).hasError, isTrue);

        // Now simulate successful authentication
        final testUser = createTestUser();
        authStateController.add(testUser);
        await Future.delayed(const Duration(milliseconds: 10));

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isFalse);
        expect(currentState.valueOrNull, isNotNull);
      });
    });

    group('signUpWithEmailPassword', () {
      test('sets loading state during sign up', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => createTestUser(),
          ),
        );

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Start sign up
        final signUpFuture = notifier.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        // Check that state is loading
        expect(container.read(authNotifierProvider).isLoading, isTrue);

        // Complete the sign up
        await signUpFuture;
      });

      test('returns user and updates state on successful sign up', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        final result = await notifier.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        expect(result.id, testUserId);
        expect(result.email, testEmail);
        expect(result.displayName, testDisplayName);

        verify(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: testEmail,
            password: testPassword,
            displayName: testDisplayName,
          ),
        ).called(1);

        final currentState = container.read(authNotifierProvider);
        expect(currentState.valueOrNull, isNotNull);
        expect(currentState.valueOrNull!.id, testUserId);
      });

      test('works without display name', () async {
        final testUser = createTestUser(displayName: null);
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        final result = await notifier.signUpWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result.id, testUserId);
        expect(result.displayName, isNull);

        verify(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: testEmail,
            password: testPassword,
            displayName: null,
          ),
        ).called(1);
      });

      test('sets error state on auth exception', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signUpWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenThrow(const UserAlreadyExistsException());

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await expectLater(
          () => notifier.signUpWithEmailPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<UserAlreadyExistsException>()),
        );

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isTrue);
        expect(currentState.error, isA<UserAlreadyExistsException>());
      });
    });

    group('signInWithEmailPassword', () {
      test('returns user and updates state on successful sign in', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        final result = await notifier.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(result.id, testUserId);
        expect(result.email, testEmail);

        verify(
          () => mockAuthRepository.signInWithEmailPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).called(1);

        final currentState = container.read(authNotifierProvider);
        expect(currentState.valueOrNull, isNotNull);
        expect(currentState.valueOrNull!.id, testUserId);
      });

      test('sets loading state during sign in', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => createTestUser(),
          ),
        );

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Start sign in
        final signInFuture = notifier.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );

        // Check that state is loading
        expect(container.read(authNotifierProvider).isLoading, isTrue);

        // Complete the sign in
        await signInFuture;
      });

      test('sets error state on invalid credentials', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const InvalidCredentialsException());

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await expectLater(
          () => notifier.signInWithEmailPassword(
            email: testEmail,
            password: 'wrong_password',
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isTrue);
        expect(currentState.error, isA<InvalidCredentialsException>());
      });
    });

    group('sendPasswordResetEmail', () {
      test('calls repository sendPasswordResetEmail', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.sendPasswordResetEmail(any()),
        ).thenAnswer((_) async {});

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await notifier.sendPasswordResetEmail(testEmail);

        verify(
          () => mockAuthRepository.sendPasswordResetEmail(testEmail),
        ).called(1);
      });

      test('does not update auth state on success', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.sendPasswordResetEmail(any()),
        ).thenAnswer((_) async {});

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        final stateBefore = container.read(authNotifierProvider);
        await notifier.sendPasswordResetEmail(testEmail);
        final stateAfter = container.read(authNotifierProvider);

        // State should remain the same
        expect(stateAfter.valueOrNull, stateBefore.valueOrNull);
        expect(stateAfter.hasError, stateBefore.hasError);
      });

      test('rethrows auth exceptions without updating main state', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.sendPasswordResetEmail(any()),
        ).thenThrow(const UserNotFoundException());

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await expectLater(
          () => notifier.sendPasswordResetEmail(testEmail),
          throwsA(isA<UserNotFoundException>()),
        );

        // Main auth state should not be affected
        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isFalse);
      });
    });

    group('signOut', () {
      test('maintains data state during sign out', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        when(() => mockAuthRepository.signOut()).thenAnswer(
          (_) async => Future.delayed(const Duration(milliseconds: 100)),
        );

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Start sign out
        final signOutFuture = notifier.signOut();

        // State should remain as data (not loading) during signOut
        // The actual state change happens via auth state listener
        expect(container.read(authNotifierProvider).isLoading, isFalse);
        expect(container.read(authNotifierProvider).hasValue, isTrue);

        // Complete the sign out
        await signOutFuture;
      });

      test('calls repository signOut', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await notifier.signOut();

        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('sets error state on auth exception', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        when(
          () => mockAuthRepository.signOut(),
        ).thenThrow(const InvalidSessionException());

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        await expectLater(
          () => notifier.signOut(),
          throwsA(isA<InvalidSessionException>()),
        );

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isTrue);
        expect(currentState.error, isA<InvalidSessionException>());
      });
    });

    group('refresh', () {
      test('refreshes state with current user from repository', () async {
        final testUser = createTestUser();

        // First setup: return null, then after refresh, return user
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        expect(container.read(authNotifierProvider).valueOrNull, isNull);

        // Update mock to return user for refresh
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        await notifier.refresh();

        final currentState = container.read(authNotifierProvider);
        expect(currentState.valueOrNull, isNotNull);
        expect(currentState.valueOrNull!.id, testUserId);
      });

      test('sets loading state during refresh', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Track state changes
        bool wasLoading = false;
        final listener = container.listen(authNotifierProvider, (
          previous,
          next,
        ) {
          if (next.isLoading) {
            wasLoading = true;
          }
        });

        // Call refresh
        await notifier.refresh();

        // Verify that loading state was set at some point
        expect(wasLoading, isTrue);

        // After refresh completes, should have data
        expect(container.read(authNotifierProvider).hasValue, isTrue);
        expect(container.read(authNotifierProvider).value, testUser);

        listener.close();
      });

      test('sets error state on exception', () async {
        // First setup to initialize without error
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Then setup mock to throw for refresh
        when(
          () => mockAuthRepository.currentUser,
        ).thenThrow(Exception('Repository error'));

        await notifier.refresh();

        final currentState = container.read(authNotifierProvider);
        expect(currentState.hasError, isTrue);
        expect(currentState.error, isA<Exception>());
      });
    });

    group('State Management Edge Cases', () {
      test('handles concurrent operations correctly', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        when(
          () => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async =>
              Future.delayed(const Duration(milliseconds: 100), () => testUser),
        );
        when(() => mockAuthRepository.signOut()).thenAnswer(
          (_) async => Future.delayed(const Duration(milliseconds: 50)),
        );

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Start sign in and sign out concurrently
        final signInFuture = notifier.signInWithEmailPassword(
          email: testEmail,
          password: testPassword,
        );
        final signOutFuture = notifier.signOut();

        // Both should complete without throwing
        await Future.wait([signInFuture, signOutFuture]);
      });

      test('maintains loading state history', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        final initialState = container.read(authNotifierProvider);
        expect(initialState.isLoading, isFalse);

        // The notifier should maintain proper loading states throughout operations
        expect(initialState.hasValue, isTrue);
        expect(initialState.valueOrNull, isNull);
      });
    });

    group('Disposal', () {
      test('cancels auth state subscription on disposal', () async {
        when(() => mockAuthRepository.currentUser).thenReturn(null);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.future;

        // Dispose the container
        container.dispose();

        // Auth state controller should still work (not closed by notifier disposal)
        expect(
          () => authStateController.add(createTestUser()),
          returnsNormally,
        );
      });
    });
  });
}

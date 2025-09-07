import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

void main() {
  group('Auth Providers', () {
    late MockAuthRepository mockAuthRepository;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late ProviderContainer container;

    const testUserId = 'test-user-123';
    const testEmail = 'test@example.com';
    const testDisplayName = 'Test User';
    const testPassword = 'testPassword123';
    final testCreatedAt = DateTime(2023, 1, 1);

    AuthUser createTestUser() {
      return AuthUser(
        id: testUserId,
        email: testEmail,
        displayName: testDisplayName,
        isEmailVerified: true,
        createdAt: testCreatedAt,
      );
    }

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const InvalidCredentialsException());
    });

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();

      // Set up mock Supabase client
      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
      when(
        () => mockGoTrueClient.onAuthStateChange,
      ).thenAnswer((_) => const Stream.empty());

      // Set up default mock behaviors
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      container.dispose();
    });

    group('supabaseClientProvider', () {
      test('throws UnimplementedError when not overridden', () {
        container = ProviderContainer();

        expect(
          () => container.read(supabaseClientProvider),
          throwsA(
            isA<UnimplementedError>().having(
              (e) => e.message,
              'message',
              contains('supabaseClientProvider must be overridden'),
            ),
          ),
        );
      });

      test('returns overridden Supabase client', () {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
          ],
        );

        final client = container.read(supabaseClientProvider);

        expect(client, equals(mockSupabaseClient));
      });
    });

    group('authRepositoryProviderImpl', () {
      test('creates SupabaseAuthRepository with Supabase client', () {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
          ],
        );

        final repository = container.read(authRepositoryProviderImpl);

        expect(repository, isNotNull);
        // We can't directly test the type since it's implementation detail,
        // but we can verify it behaves like an AuthRepository
        expect(repository, isA<AuthRepository>());
      });
    });

    group('authNotifierProvider', () {
      test('creates AuthNotifier with dependencies', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final notifier = container.read(authNotifierProvider.notifier);

        expect(notifier, isNotNull);
        // Verify it initializes properly by checking the future
        final state = await notifier.future;
        expect(state, isNull); // No current user
      });

      test('initializes with current user from repository', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final state = await container.read(authNotifierProvider.future);

        expect(state, isNotNull);
        expect(state!.id, testUserId);
        expect(state.email, testEmail);
      });
    });

    group('authStateProvider', () {
      test('provides AsyncValue from authNotifierProvider', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Wait for initialization
        await container.read(authNotifierProvider.future);

        final authState = container.read(authStateProvider);

        expect(authState, isA<AsyncValue<AuthUser?>>());
        expect(authState.valueOrNull, isNull);
        expect(authState.hasValue, isTrue);
      });

      test('reflects loading state', () {
        // Create a container that doesn't complete initialization immediately
        when(
          () => mockAuthRepository.currentUser,
        ).thenAnswer((_) => throw Exception('Delayed initialization'));

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final authState = container.read(authStateProvider);

        expect(authState.isLoading, isTrue);
      });

      test('reflects error state', () async {
        when(
          () => mockAuthRepository.currentUser,
        ).thenThrow(const NetworkAuthException());

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Force the notifier to initialize and get error state
        try {
          await container.read(authNotifierProvider.future);
        } catch (_) {
          // Expected to throw
        }

        final authState = container.read(authStateProvider);

        expect(authState.hasError, isTrue);
        expect(authState.error, isA<NetworkAuthException>());
      });
    });

    group('currentUserProvider', () {
      test('returns null when not authenticated', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final currentUser = container.read(currentUserProvider);

        expect(currentUser, isNull);
      });

      test('returns user when authenticated', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final currentUser = container.read(currentUserProvider);

        expect(currentUser, isNotNull);
        expect(currentUser!.id, testUserId);
        expect(currentUser.email, testEmail);
      });

      test('returns null when loading', () {
        // Create a container that stays in loading state
        when(
          () => mockAuthRepository.currentUser,
        ).thenAnswer((_) => throw Exception('Loading...'));

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final currentUser = container.read(currentUserProvider);

        expect(currentUser, isNull);
      });

      test('returns null when in error state', () async {
        when(
          () => mockAuthRepository.currentUser,
        ).thenThrow(const NetworkAuthException());

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Force initialization to error state
        try {
          await container.read(authNotifierProvider.future);
        } catch (_) {
          // Expected to throw
        }

        final currentUser = container.read(currentUserProvider);

        expect(currentUser, isNull);
      });
    });

    group('isAuthenticatedProvider', () {
      test('returns false when not authenticated', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final isAuthenticated = container.read(isAuthenticatedProvider);

        expect(isAuthenticated, isFalse);
      });

      test('returns true when authenticated', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final isAuthenticated = container.read(isAuthenticatedProvider);

        expect(isAuthenticated, isTrue);
      });

      test('returns false when loading', () {
        when(
          () => mockAuthRepository.currentUser,
        ).thenAnswer((_) => throw Exception('Loading...'));

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final isAuthenticated = container.read(isAuthenticatedProvider);

        expect(isAuthenticated, isFalse);
      });

      test('returns false when in error state', () async {
        when(
          () => mockAuthRepository.currentUser,
        ).thenThrow(const NetworkAuthException());

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Force initialization to error state
        try {
          await container.read(authNotifierProvider.future);
        } catch (_) {
          // Expected to throw
        }

        final isAuthenticated = container.read(isAuthenticatedProvider);

        expect(isAuthenticated, isFalse);
      });
    });

    group('isAuthLoadingProvider', () {
      test('returns false when not loading', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final isLoading = container.read(isAuthLoadingProvider);

        expect(isLoading, isFalse);
      });

      test('returns true when loading', () {
        when(
          () => mockAuthRepository.currentUser,
        ).thenAnswer((_) => throw Exception('Loading...'));

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final isLoading = container.read(isAuthLoadingProvider);

        expect(isLoading, isTrue);
      });
    });

    group('authErrorProvider', () {
      test('returns null when no error', () async {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        await container.read(authNotifierProvider.future);
        final error = container.read(authErrorProvider);

        expect(error, isNull);
      });

      test('returns error when in error state', () async {
        const testError = NetworkAuthException();
        when(() => mockAuthRepository.currentUser).thenThrow(testError);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Force initialization to error state
        try {
          await container.read(authNotifierProvider.future);
        } catch (_) {
          // Expected to throw
        }

        final error = container.read(authErrorProvider);

        expect(error, isNotNull);
        expect(error, equals(testError));
      });
    });

    group('authStateStreamProvider', () {
      test('provides auth state changes stream', () async {
        // Set up a stream controller to provide test data
        final streamController = StreamController<AuthUser?>.broadcast();
        when(
          () => mockAuthRepository.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // Listen to the stream provider to start the subscription
        final subscription = container.listen(
          authStateStreamProvider,
          (_, _) {},
        );

        // Emit a value to complete the future
        streamController.add(null);

        // Wait for the stream to connect
        await container.read(authStateStreamProvider.future);

        // Verify authStateChanges was called
        verify(() => mockAuthRepository.authStateChanges).called(1);

        // Clean up
        subscription.close();
        await streamController.close();
      });
    });

    group('authControllerProvider', () {
      test('creates AuthController with provider reference', () {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final controller = container.read(authControllerProvider);

        expect(controller, isNotNull);
        expect(controller, isA<AuthController>());
      });
    });

    group('AuthController', () {
      late AuthController controller;

      setUp(() {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        controller = container.read(authControllerProvider);
      });

      group('signInWithMagicLink', () {
        test('calls notifier signInWithMagicLink', () async {
          when(
            () => mockAuthRepository.signInWithMagicLink(any()),
          ).thenAnswer((_) async {});

          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          await controller.signInWithMagicLink(testEmail);

          verify(
            () => mockAuthRepository.signInWithMagicLink(testEmail),
          ).called(1);
        });
      });

      group('signUpWithEmailPassword', () {
        test(
          'calls notifier signUpWithEmailPassword and returns user',
          () async {
            final testUser = createTestUser();
            when(
              () => mockAuthRepository.signUpWithEmailPassword(
                email: any(named: 'email'),
                password: any(named: 'password'),
                displayName: any(named: 'displayName'),
              ),
            ).thenAnswer((_) async => testUser);

            // Initialize notifier first
            await container.read(authNotifierProvider.future);

            final result = await controller.signUpWithEmailPassword(
              email: testEmail,
              password: testPassword,
              displayName: testDisplayName,
            );

            expect(result.id, testUserId);
            verify(
              () => mockAuthRepository.signUpWithEmailPassword(
                email: testEmail,
                password: testPassword,
                displayName: testDisplayName,
              ),
            ).called(1);
          },
        );
      });

      group('signInWithEmailPassword', () {
        test(
          'calls notifier signInWithEmailPassword and returns user',
          () async {
            final testUser = createTestUser();
            when(
              () => mockAuthRepository.signInWithEmailPassword(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ),
            ).thenAnswer((_) async => testUser);

            // Initialize notifier first
            await container.read(authNotifierProvider.future);

            final result = await controller.signInWithEmailPassword(
              email: testEmail,
              password: testPassword,
            );

            expect(result.id, testUserId);
            verify(
              () => mockAuthRepository.signInWithEmailPassword(
                email: testEmail,
                password: testPassword,
              ),
            ).called(1);
          },
        );
      });

      group('sendPasswordResetEmail', () {
        test('calls notifier sendPasswordResetEmail', () async {
          when(
            () => mockAuthRepository.sendPasswordResetEmail(any()),
          ).thenAnswer((_) async {});

          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          await controller.sendPasswordResetEmail(testEmail);

          verify(
            () => mockAuthRepository.sendPasswordResetEmail(testEmail),
          ).called(1);
        });
      });

      group('signOut', () {
        test('calls notifier signOut', () async {
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          await controller.signOut();

          verify(() => mockAuthRepository.signOut()).called(1);
        });
      });

      group('refresh', () {
        test('calls notifier refresh', () async {
          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          await controller.refresh();

          // Verify that refresh was called by checking currentUser was accessed
          verify(() => mockAuthRepository.currentUser).called(greaterThan(0));
        });
      });

      group('Getters', () {
        test('currentUser returns value from currentUserProvider', () async {
          final testUser = createTestUser();
          when(() => mockAuthRepository.currentUser).thenReturn(testUser);

          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          final currentUser = controller.currentUser;

          expect(currentUser, isNotNull);
          expect(currentUser!.id, testUserId);
        });

        test(
          'isAuthenticated returns value from isAuthenticatedProvider',
          () async {
            final testUser = createTestUser();
            when(() => mockAuthRepository.currentUser).thenReturn(testUser);

            // Initialize notifier first
            await container.read(authNotifierProvider.future);

            final isAuthenticated = controller.isAuthenticated;

            expect(isAuthenticated, isTrue);
          },
        );

        test('isLoading returns value from isAuthLoadingProvider', () async {
          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          final isLoading = controller.isLoading;

          expect(isLoading, isFalse);
        });

        test('error returns value from authErrorProvider', () async {
          // Initialize notifier first
          await container.read(authNotifierProvider.future);

          final error = controller.error;

          expect(error, isNull);
        });
      });
    });

    group('getAuthProviderOverrides', () {
      test('returns list of provider overrides', () {
        final overrides = getAuthProviderOverrides();

        expect(overrides, isNotEmpty);
        expect(overrides.length, equals(1));
        expect(overrides.first, isA<Override>());
      });

      test('overrides work correctly with SupabaseClient', () {
        final overrides = getAuthProviderOverrides();

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            ...overrides,
          ],
        );

        final repository = container.read(authRepositoryProvider);

        expect(repository, isNotNull);
        expect(repository, isA<AuthRepository>());
      });
    });

    group('Provider Dependencies', () {
      test('authNotifierProvider depends on authRepositoryProviderImpl', () {
        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
          ],
        );

        // This should work because authNotifierProvider depends on authRepositoryProviderImpl
        final notifier = container.read(authNotifierProvider.notifier);

        expect(notifier, isNotNull);
      });

      test('providers are properly connected in dependency chain', () async {
        final testUser = createTestUser();
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);

        container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProviderImpl.overrideWithValue(mockAuthRepository),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        // All these providers should work together
        await container.read(authNotifierProvider.future);
        final currentUser = container.read(currentUserProvider);
        final isAuthenticated = container.read(isAuthenticatedProvider);
        final isLoading = container.read(isAuthLoadingProvider);
        final error = container.read(authErrorProvider);

        expect(currentUser, isNotNull);
        expect(isAuthenticated, isTrue);
        expect(isLoading, isFalse);
        expect(error, isNull);
      });
    });
  });
}

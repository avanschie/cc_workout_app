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

class MockListener<T> extends Mock {
  void call(T? previous, T next);
}

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
            isA<Exception>().having(
              (e) => e.toString(),
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
        container.read(authNotifierProvider);

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
        container.read(authNotifierProvider);

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
    });

    group('authStateStreamProvider', () {});

    group('getAuthProviderOverrides', () {
      test('returns list of provider overrides', () {
        final overrides = getAuthProviderOverrides();

        expect(overrides, isNotEmpty);
        expect(overrides.length, equals(1));
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
    });
  });
}

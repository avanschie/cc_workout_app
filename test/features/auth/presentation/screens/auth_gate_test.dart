import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';
import 'package:cc_workout_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_workout_app/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/auth/application/notifiers/auth_notifier.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/auth_gate.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/auth_loading_screen.dart';
import 'package:cc_workout_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:cc_workout_app/core/navigation/main_navigation_shell.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

/// Robot class for testing AuthGate widget interactions
class AuthGateRobot {
  const AuthGateRobot(this.tester);

  final WidgetTester tester;

  Future<void> pumpAuthGate({
    AuthUser? currentUser,
    bool hasError = false,
    Object? error,
    bool isLoading = false,
  }) async {
    final mockRepository = MockAuthRepository();

    // Set up mock behavior
    when(() => mockRepository.currentUser).thenReturn(currentUser);
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => Stream.value(currentUser));

    AsyncValue<AuthUser?> authState;
    if (hasError && error != null) {
      authState = AsyncValue.error(error, StackTrace.current);
    } else if (isLoading) {
      authState = const AsyncValue.loading();
    } else {
      authState = AsyncValue.data(currentUser);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          authStateProvider.overrideWith((ref) => authState),
        ],
        child: const AuthGate(),
      ),
    );
  }

  Future<void> pumpAuthGateWithDebugInfo({
    AuthUser? currentUser,
    bool hasError = false,
    Object? error,
    bool isLoading = false,
  }) async {
    final mockRepository = MockAuthRepository();

    when(() => mockRepository.currentUser).thenReturn(currentUser);
    when(
      () => mockRepository.authStateChanges,
    ).thenAnswer((_) => Stream.value(currentUser));

    AsyncValue<AuthUser?> authState;
    if (hasError && error != null) {
      authState = AsyncValue.error(error, StackTrace.current);
    } else if (isLoading) {
      authState = const AsyncValue.loading();
    } else {
      authState = AsyncValue.data(currentUser);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          authStateProvider.overrideWith((ref) => authState),
        ],
        child: const AuthGateWithDebugInfo(),
      ),
    );
  }

  // Finders
  Finder get materialApp => find.byType(MaterialApp);
  Finder get authInitializingScreen => find.byType(AuthInitializingScreen);
  Finder get mainNavigationShell => find.byType(MainNavigationShell);
  Finder get authNavigator => find.byType(AuthNavigator);
  Finder get authErrorScreen => find.byType(AuthErrorScreen);
  Finder get signInScreen => find.byType(SignInScreen);
  Finder get debugInfoBanner => find.text('Auth: ');

  // Actions
  Future<void> tapRetryButton() async {
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
  }

  Future<void> navigateToSignUp() async {
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
  }

  Future<void> navigateToForgotPassword() async {
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
  }

  // Assertions
  void expectLoadingScreen() {
    expect(authInitializingScreen, findsOneWidget);
  }

  void expectMainApp() {
    expect(mainNavigationShell, findsOneWidget);
  }

  void expectAuthScreens() {
    expect(authNavigator, findsOneWidget);
    expect(signInScreen, findsOneWidget);
  }

  void expectErrorScreen() {
    expect(authErrorScreen, findsOneWidget);
  }

  void expectMaterialAppWithTheme() {
    expect(materialApp, findsOneWidget);

    final materialAppWidget = tester.widget<MaterialApp>(materialApp);
    expect(materialAppWidget.title, 'Rep Max Tracker');
    expect(materialAppWidget.theme, isNotNull);
    expect(materialAppWidget.darkTheme, isNotNull);
    expect(materialAppWidget.themeMode, ThemeMode.system);
    expect(materialAppWidget.debugShowCheckedModeBanner, isFalse);
  }

  void expectRoutesDefined() {
    final materialAppWidget = tester.widget<MaterialApp>(materialApp);
    expect(materialAppWidget.routes, isNotNull);
    expect(materialAppWidget.routes, contains('/sign-in'));
    expect(materialAppWidget.routes, contains('/sign-up'));
    expect(materialAppWidget.routes, contains('/forgot-password'));
  }

  void expectDebugInfo() {
    expect(find.textContaining('Auth:'), findsOneWidget);
  }
}

AuthUser createTestUser({
  String id = 'test-id',
  String email = 'test@example.com',
  String? displayName = 'Test User',
}) {
  return AuthUser(
    id: id,
    email: email,
    displayName: displayName,
    isEmailVerified: true,
    createdAt: DateTime(2023, 1, 1),
  );
}

void main() {
  group('AuthGate', () {
    late AuthGateRobot robot;

    setUp(() {
      // Register fallback values for mocktail
      registerFallbackValue(const InvalidCredentialsException());
    });

    testWidgets('displays loading screen when auth state is loading', (
      tester,
    ) async {
      robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(isLoading: true);

      robot.expectLoadingScreen();
      robot.expectMaterialAppWithTheme();
    });

    testWidgets('displays main app when user is authenticated', (tester) async {
      robot = AuthGateRobot(tester);
      final testUser = createTestUser();

      await robot.pumpAuthGate(currentUser: testUser);

      robot.expectMainApp();
      robot.expectMaterialAppWithTheme();
    });

    testWidgets('displays auth screens when user is not authenticated', (
      tester,
    ) async {
      robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      robot.expectAuthScreens();
      robot.expectMaterialAppWithTheme();
    });

    testWidgets('displays error screen when auth state has error', (
      tester,
    ) async {
      robot = AuthGateRobot(tester);
      const error = NetworkAuthException('Network error');

      await robot.pumpAuthGate(hasError: true, error: error);

      robot.expectErrorScreen();
      robot.expectMaterialAppWithTheme();
    });

    testWidgets('configures MaterialApp with correct properties', (
      tester,
    ) async {
      robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      robot.expectMaterialAppWithTheme();
      robot.expectRoutesDefined();
    });

    testWidgets('error screen displays retry functionality', (tester) async {
      robot = AuthGateRobot(tester);
      const error = ServiceUnavailableException('Service unavailable');

      await robot.pumpAuthGate(hasError: true, error: error);

      robot.expectErrorScreen();

      // Verify retry button exists
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('routes are properly configured', (tester) async {
      robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      final materialAppWidget = tester.widget<MaterialApp>(robot.materialApp);

      // Test that routes exist and return correct widgets
      final signInRoute = materialAppWidget.routes!['/sign-in']!;
      final signInWidget = signInRoute(tester.element(robot.materialApp));
      expect(signInWidget, isA<SignInScreen>());

      // We can't easily test navigation in this setup, but we can verify routes exist
      robot.expectRoutesDefined();
    });
  });

  group('AuthNavigator', () {
    testWidgets('displays SignInScreen by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthNavigator()));

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(AuthNavigator), findsOneWidget);
    });

    testWidgets('handles PopScope correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthNavigator()));

      final popScope = find.byType(PopScope);
      expect(popScope, findsOneWidget);

      final popScopeWidget = tester.widget<PopScope>(popScope);
      expect(popScopeWidget.canPop, isFalse);
    });

    testWidgets('contains Navigator with correct properties', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthNavigator()));

      final navigator = find.byType(Navigator).last; // Get the inner Navigator
      expect(navigator, findsOneWidget);

      // Verify initial route is correct
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });

  group('AuthErrorScreen', () {
    testWidgets('displays error information correctly', (tester) async {
      const error = NetworkAuthException('Test error message');
      var retryCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(error: error, onRetry: () => retryCallCount++),
        ),
      );

      // Check for error elements
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Authentication Error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('Troubleshooting'), findsOneWidget);
    });

    testWidgets('retry button calls onRetry callback', (tester) async {
      const error = InvalidCredentialsException();
      var retryCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(error: error, onRetry: () => retryCallCount++),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(retryCallCount, 1);
    });

    testWidgets('displays appropriate error message based on error type', (
      tester,
    ) async {
      final testCases = [
        (const NetworkAuthException('Network error'), 'network'),
        (Exception('Timeout occurred'), 'timeout'),
        (Exception('Server error'), 'service'),
        (Exception('Config error'), 'configuration'),
        (Exception('Unknown error'), 'Something went wrong'),
      ];

      for (final (error, expectedMessagePart) in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: AuthErrorScreen(error: error, onRetry: () {}),
          ),
        );

        final errorText = find.textContaining(
          expectedMessagePart,
          findRichText: true,
        );
        expect(
          errorText,
          findsAtLeastNWidgets(1),
          reason: 'Expected to find "$expectedMessagePart" for error: $error',
        );

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('displays troubleshooting information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(error: Exception('Test error'), onRetry: () {}),
        ),
      );

      expect(find.text('Troubleshooting'), findsOneWidget);
      expect(find.textContaining('internet connection'), findsOneWidget);
      expect(find.textContaining('app is up to date'), findsOneWidget);
      expect(find.textContaining('restarting the app'), findsOneWidget);
      expect(find.textContaining('contact support'), findsOneWidget);
    });
  });

  group('AuthGateWithDebugInfo', () {
    late AuthGateRobot robot;

    testWidgets('shows debug info in debug builds', (tester) async {
      robot = AuthGateRobot(tester);

      await robot.pumpAuthGateWithDebugInfo(currentUser: null);

      // Debug info should be shown based on the _shouldShowDebugInfo logic
      // Since we're in a test environment, this should behave like debug mode
      robot.expectDebugInfo();
    });

    testWidgets('debug info shows correct auth status', (tester) async {
      robot = AuthGateRobot(tester);
      final testUser = createTestUser();

      // Test authenticated state
      await robot.pumpAuthGateWithDebugInfo(currentUser: testUser);
      expect(find.textContaining('Authenticated'), findsOneWidget);

      // Test loading state
      await robot.pumpAuthGateWithDebugInfo(isLoading: true);
      expect(find.textContaining('Loading'), findsOneWidget);

      // Test error state
      await robot.pumpAuthGateWithDebugInfo(
        hasError: true,
        error: const NetworkAuthException(),
      );
      expect(find.textContaining('Error'), findsOneWidget);

      // Test not authenticated state
      await robot.pumpAuthGateWithDebugInfo(currentUser: null);
      expect(find.textContaining('Not authenticated'), findsOneWidget);
    });
  });

  group('Theme Configuration', () {
    testWidgets('builds correct light theme', (tester) async {
      const robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      final materialApp = tester.widget<MaterialApp>(robot.materialApp);
      final theme = materialApp.theme!;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary.value, 0xFF6B46C1); // Purple seed color
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.floatingActionButtonTheme.elevation, 4);
      expect(theme.cardTheme.elevation, 2);
    });

    testWidgets('builds correct dark theme', (tester) async {
      const robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      final materialApp = tester.widget<MaterialApp>(robot.materialApp);
      final darkTheme = materialApp.darkTheme!;

      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
      expect(darkTheme.appBarTheme.centerTitle, isTrue);
      expect(darkTheme.appBarTheme.elevation, 0);
    });

    testWidgets('uses system theme mode', (tester) async {
      const robot = AuthGateRobot(tester);

      await robot.pumpAuthGate(currentUser: null);

      final materialApp = tester.widget<MaterialApp>(robot.materialApp);
      expect(materialApp.themeMode, ThemeMode.system);
    });
  });

  group('Error Message Mapping', () {
    testWidgets('maps network errors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(
            error: Exception('network connection failed'),
            onRetry: () {},
          ),
        ),
      );

      expect(
        find.textContaining('connect to the authentication service'),
        findsOneWidget,
      );
      expect(find.textContaining('internet connection'), findsOneWidget);
    });

    testWidgets('maps timeout errors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(
            error: Exception('request timeout'),
            onRetry: () {},
          ),
        ),
      );

      expect(find.textContaining('timed out'), findsOneWidget);
    });

    testWidgets('maps server errors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(
            error: Exception('server error occurred'),
            onRetry: () {},
          ),
        ),
      );

      expect(find.textContaining('temporarily unavailable'), findsOneWidget);
    });

    testWidgets('maps config errors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuthErrorScreen(
            error: Exception('configuration initialization failed'),
            onRetry: () {},
          ),
        ),
      );

      expect(find.textContaining('configuration error'), findsOneWidget);
    });
  });
}

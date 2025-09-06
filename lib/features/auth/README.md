# Authentication Feature

This directory contains the complete authentication implementation following the 4-layer architecture pattern with proper domain/data layer separation.

## Architecture Overview

The authentication feature is organized using Andrea Bizzotto's 4-layer architecture:

```
lib/features/auth/
├── domain/                    # Domain Layer
│   ├── entities/             # Domain entities (AuthUser)
│   ├── repositories/         # Repository interfaces
│   └── exceptions/           # Domain-specific exceptions
├── data/                     # Data Layer
│   ├── repositories/         # Repository implementations
│   └── models/              # Data Transfer Objects (DTOs)
└── application/             # Application Layer
    ├── notifiers/           # State management (AsyncNotifier)
    └── providers/           # Riverpod providers & controllers
```

## Key Components

### Domain Layer

**AuthUser Entity** (`domain/entities/auth_user.dart`)
- Immutable domain model using Freezed
- Contains user profile information (id, email, displayName, etc.)
- Supports JSON serialization for persistence
- Factory method for mapping from Supabase User objects

**AuthRepository Interface** (`domain/repositories/auth_repository.dart`)
- Abstract repository defining authentication contracts
- Methods: signInWithMagicLink, signUpWithEmailPassword, signInWithEmailPassword, sendPasswordResetEmail, signOut
- Returns domain entities, not infrastructure types
- Stream-based auth state changes

**Auth Exceptions** (`domain/exceptions/auth_exceptions.dart`)
- Domain-specific exception hierarchy
- Covers common auth scenarios: InvalidCredentials, UserNotFound, WeakPassword, etc.
- Includes error codes for precise error handling

### Data Layer

**SupabaseAuthRepository** (`data/repositories/supabase_auth_repository.dart`)
- Concrete implementation using Supabase as the authentication provider
- Maps Supabase exceptions to domain exceptions
- Handles environment-specific behavior (email verification requirements)
- Manages auth state stream with proper domain entity mapping

**AuthUserDto** (`data/models/auth_user_dto.dart`)
- Data Transfer Object for mapping between Supabase User and AuthUser domain entity
- Handles complex field mapping and data transformation
- Bidirectional conversion: fromSupabaseUser(), toDomain(), fromDomain()

### Application Layer

**AuthNotifier** (`application/notifiers/auth_notifier.dart`)
- AsyncNotifier managing authentication state
- Handles all auth operations: sign up, sign in, sign out, password reset
- Environment-specific auto-login for development
- Proper error handling and state management

**Auth Providers** (`application/providers/auth_providers.dart`)
- Riverpod provider configuration
- AuthController for clean UI interaction
- Provider overrides for dependency injection
- Convenience providers for common auth states

## Environment Configuration

Authentication behavior is customized per environment through `EnvConfig`:

```dart
// Local Development
requireEmailVerification: false  // Skip email verification
enableAutoSignIn: true          // Auto-login for convenience
sessionTimeoutMinutes: 120      // Longer sessions

// Production
requireEmailVerification: true  // Require email verification
enableAutoSignIn: false        // No auto-login for security
sessionTimeoutMinutes: 30       // Shorter sessions
```

## Usage Examples

### Basic Sign Up
```dart
final authController = ref.read(authControllerProvider);

try {
  final user = await authController.signUpWithEmailPassword(
    email: 'user@example.com',
    password: 'securePassword123',
    displayName: 'John Doe',
  );
  // Handle successful sign up
} on AuthException catch (e) {
  // Handle specific auth errors
  if (e is WeakPasswordException) {
    // Show password strength requirements
  } else if (e is UserAlreadyExistsException) {
    // Show user exists message
  }
}
```

### Observing Auth State
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      loading: () => CircularProgressIndicator(),
      data: (user) => user != null 
        ? AuthenticatedView(user: user)
        : UnauthenticatedView(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

### Provider Setup

In your main app, configure the auth providers:

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Configure Supabase client
        supabaseClientProvider.overrideWithValue(supabaseClient),
        // Add auth provider overrides
        ...getAuthProviderOverrides(),
      ],
      child: MyApp(),
    ),
  );
}
```

## Error Handling

The authentication system provides comprehensive error handling:

1. **Domain Exceptions**: Clean, typed exceptions for business logic
2. **Infrastructure Mapping**: Supabase errors mapped to domain exceptions
3. **User-Friendly Messages**: Meaningful error messages for UI display
4. **Error Recovery**: Proper state management for error scenarios

## Testing

The implementation includes comprehensive tests:

- **Domain Entity Tests**: AuthUser creation, serialization, copying
- **Exception Tests**: Proper exception creation and messages
- **Repository Tests**: Mock-based testing of auth operations
- **State Management Tests**: AsyncNotifier behavior verification

## Development Guidelines

1. **Add New Auth Methods**: Extend the AuthRepository interface first, then implement in SupabaseAuthRepository
2. **Error Handling**: Create specific domain exceptions for new error scenarios
3. **Environment Behavior**: Use EnvConfig for environment-specific customizations
4. **Testing**: Write tests for both happy path and error scenarios
5. **Documentation**: Update this README when adding new functionality

## Security Considerations

- Email verification required in production environments
- Passwords validated according to security requirements
- Sessions timeout based on environment settings
- Sensitive data never logged or exposed
- Rate limiting handled at the Supabase level
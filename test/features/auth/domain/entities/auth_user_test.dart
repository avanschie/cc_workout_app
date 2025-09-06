import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUser', () {
    const testId = 'test-id-123';
    const testEmail = 'test@example.com';
    const testDisplayName = 'Test User';
    const testPhotoUrl = 'https://example.com/photo.jpg';
    final testCreatedAt = DateTime(2023, 1, 1);
    final testLastSignInAt = DateTime(2023, 1, 2);
    const testUserMetadata = {
      'display_name': 'Test User',
      'avatar_url': 'https://example.com/photo.jpg',
    };
    const testAppMetadata = {'provider': 'email', 'role': 'user'};

    group('Constructor', () {
      test('creates AuthUser with required fields', () {
        final user = AuthUser(
          id: testId,
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(user.id, testId);
        expect(user.email, testEmail);
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isTrue);
        expect(user.createdAt, testCreatedAt);
        expect(user.lastSignInAt, isNull);
        expect(user.userMetadata, isEmpty);
        expect(user.appMetadata, isEmpty);
      });

      test('creates AuthUser with all fields', () {
        final user = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
          userMetadata: testUserMetadata,
          appMetadata: testAppMetadata,
        );

        expect(user.id, testId);
        expect(user.email, testEmail);
        expect(user.displayName, testDisplayName);
        expect(user.photoUrl, testPhotoUrl);
        expect(user.isEmailVerified, isTrue);
        expect(user.createdAt, testCreatedAt);
        expect(user.lastSignInAt, testLastSignInAt);
        expect(user.userMetadata, testUserMetadata);
        expect(user.appMetadata, testAppMetadata);
      });

      test('creates AuthUser with empty email when not verified', () {
        final user = AuthUser(
          id: testId,
          email: '',
          isEmailVerified: false,
          createdAt: testCreatedAt,
        );

        expect(user.email, '');
        expect(user.isEmailVerified, isFalse);
      });
    });

    group('JSON Serialization', () {
      test('converts to and from JSON with all fields', () {
        final user = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
          userMetadata: testUserMetadata,
          appMetadata: testAppMetadata,
        );

        final json = user.toJson();
        final userFromJson = AuthUser.fromJson(json);

        expect(userFromJson.id, user.id);
        expect(userFromJson.email, user.email);
        expect(userFromJson.displayName, user.displayName);
        expect(userFromJson.photoUrl, user.photoUrl);
        expect(userFromJson.isEmailVerified, user.isEmailVerified);
        expect(userFromJson.createdAt, user.createdAt);
        expect(userFromJson.lastSignInAt, user.lastSignInAt);
        expect(userFromJson.userMetadata, user.userMetadata);
        expect(userFromJson.appMetadata, user.appMetadata);
      });

      test('converts to and from JSON with minimal fields', () {
        final user = AuthUser(
          id: testId,
          email: testEmail,
          isEmailVerified: false,
          createdAt: testCreatedAt,
        );

        final json = user.toJson();
        final userFromJson = AuthUser.fromJson(json);

        expect(userFromJson.id, user.id);
        expect(userFromJson.email, user.email);
        expect(userFromJson.displayName, isNull);
        expect(userFromJson.photoUrl, isNull);
        expect(userFromJson.isEmailVerified, user.isEmailVerified);
        expect(userFromJson.createdAt, user.createdAt);
        expect(userFromJson.lastSignInAt, isNull);
        expect(userFromJson.userMetadata, isEmpty);
        expect(userFromJson.appMetadata, isEmpty);
      });

      test('handles null values in JSON', () {
        final json = {
          'id': testId,
          'email': testEmail,
          'displayName': null,
          'photoUrl': null,
          'isEmailVerified': false,
          'createdAt': testCreatedAt.toIso8601String(),
          'lastSignInAt': null,
          'userMetadata': <String, dynamic>{},
          'appMetadata': <String, dynamic>{},
        };

        final user = AuthUser.fromJson(json);

        expect(user.id, testId);
        expect(user.email, testEmail);
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.createdAt, testCreatedAt);
        expect(user.lastSignInAt, isNull);
      });
    });

    group('Supabase User Conversion', () {
      test('creates AuthUser from Supabase User with all fields', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: testAppMetadata,
          userMetadata: {
            'display_name': testDisplayName,
            'avatar_url': testPhotoUrl,
          },
          aud: 'authenticated',
          email: testEmail,
          emailConfirmedAt: testLastSignInAt.toIso8601String(),
          lastSignInAt: testLastSignInAt.toIso8601String(),
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );

        final authUser = AuthUser.fromSupabaseUser(supabaseUser);

        expect(authUser.id, testId);
        expect(authUser.email, testEmail);
        expect(authUser.displayName, testDisplayName);
        expect(authUser.photoUrl, testPhotoUrl);
        expect(authUser.isEmailVerified, isTrue);
        expect(authUser.createdAt, testCreatedAt);
        expect(authUser.lastSignInAt, testLastSignInAt);
        expect(authUser.userMetadata, contains('display_name'));
        expect(authUser.userMetadata, contains('avatar_url'));
        expect(authUser.appMetadata, testAppMetadata);
      });

      test('creates AuthUser from Supabase User with minimal fields', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );

        final authUser = AuthUser.fromSupabaseUser(supabaseUser);

        expect(authUser.id, testId);
        expect(authUser.email, testEmail);
        expect(authUser.displayName, isNull);
        expect(authUser.photoUrl, isNull);
        expect(authUser.isEmailVerified, isFalse);
        expect(authUser.createdAt, testCreatedAt);
        expect(authUser.lastSignInAt, isNull);
      });

      test('handles null email from Supabase User', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{},
          aud: 'authenticated',
          email: null,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );

        final authUser = AuthUser.fromSupabaseUser(supabaseUser);

        expect(authUser.email, '');
      });

      test('handles different metadata fields for display name', () {
        // Test display_name
        var supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const {'display_name': 'Display Name'},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        var authUser = AuthUser.fromSupabaseUser(supabaseUser);
        expect(authUser.displayName, 'Display Name');

        // Test name fallback
        supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const {'name': 'Name Field'},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        authUser = AuthUser.fromSupabaseUser(supabaseUser);
        expect(authUser.displayName, 'Name Field');

        // Test full_name fallback
        supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const {'full_name': 'Full Name'},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        authUser = AuthUser.fromSupabaseUser(supabaseUser);
        expect(authUser.displayName, 'Full Name');
      });

      test('handles different metadata fields for photo URL', () {
        // Test avatar_url
        var supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const {'avatar_url': 'avatar.jpg'},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        var authUser = AuthUser.fromSupabaseUser(supabaseUser);
        expect(authUser.photoUrl, 'avatar.jpg');

        // Test picture fallback
        supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const {'picture': 'picture.jpg'},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );
        authUser = AuthUser.fromSupabaseUser(supabaseUser);
        expect(authUser.photoUrl, 'picture.jpg');
      });
    });

    group('copyWith', () {
      late AuthUser originalUser;

      setUp(() {
        originalUser = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: false,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
          userMetadata: testUserMetadata,
          appMetadata: testAppMetadata,
        );
      });

      test('copies with modified fields', () {
        final updatedUser = originalUser.copyWith(
          displayName: 'Updated User',
          isEmailVerified: true,
          photoUrl: 'https://example.com/new-photo.jpg',
        );

        expect(updatedUser.id, originalUser.id); // Unchanged
        expect(updatedUser.email, originalUser.email); // Unchanged
        expect(updatedUser.displayName, 'Updated User'); // Changed
        expect(
          updatedUser.photoUrl,
          'https://example.com/new-photo.jpg',
        ); // Changed
        expect(updatedUser.isEmailVerified, isTrue); // Changed
        expect(updatedUser.createdAt, originalUser.createdAt); // Unchanged
        expect(
          updatedUser.lastSignInAt,
          originalUser.lastSignInAt,
        ); // Unchanged
        expect(
          updatedUser.userMetadata,
          originalUser.userMetadata,
        ); // Unchanged
        expect(updatedUser.appMetadata, originalUser.appMetadata); // Unchanged
      });

      test('copies with null values', () {
        final updatedUser = originalUser.copyWith(
          displayName: null,
          photoUrl: null,
          lastSignInAt: null,
        );

        expect(updatedUser.displayName, isNull);
        expect(updatedUser.photoUrl, isNull);
        expect(updatedUser.lastSignInAt, isNull);
      });

      test('copies with updated metadata', () {
        const newUserMetadata = {'updated': 'metadata'};
        const newAppMetadata = {'app': 'data'};

        final updatedUser = originalUser.copyWith(
          userMetadata: newUserMetadata,
          appMetadata: newAppMetadata,
        );

        expect(updatedUser.userMetadata, newUserMetadata);
        expect(updatedUser.appMetadata, newAppMetadata);
      });
    });

    group('Equality', () {
      test('compares equal AuthUsers', () {
        final user1 = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );
        final user2 = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('compares different AuthUsers', () {
        final user1 = AuthUser(
          id: testId,
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );
        final user2 = AuthUser(
          id: 'different-id',
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final user = AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        final stringRep = user.toString();

        expect(stringRep, contains(testId));
        expect(stringRep, contains(testEmail));
        expect(stringRep, contains(testDisplayName));
        expect(stringRep, contains('true')); // isEmailVerified
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:cc_workout_app/features/auth/data/models/auth_user_dto.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart'
    as domain;

void main() {
  group('AuthUserDto', () {
    const testId = 'test-id-123';
    const testEmail = 'test@example.com';
    const testDisplayName = 'Test User';
    const testPhotoUrl = 'https://example.com/photo.jpg';
    final testCreatedAt = DateTime(2023, 1, 1);
    final testLastSignInAt = DateTime(2023, 1, 2);

    group('Constructor', () {
      test('creates AuthUserDto with required fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, isNull);
        expect(dto.photoUrl, isNull);
        expect(dto.isEmailVerified, isTrue);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, isNull);
      });

      test('creates AuthUserDto with all fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
        );

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, testDisplayName);
        expect(dto.photoUrl, testPhotoUrl);
        expect(dto.isEmailVerified, isTrue);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, testLastSignInAt);
      });
    });

    group('fromSupabaseUser', () {
      test('creates AuthUserDto from Supabase User with all fields', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: const {'provider': 'email'},
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

        final dto = AuthUserDto.fromSupabaseUser(supabaseUser);

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, testDisplayName);
        expect(dto.photoUrl, testPhotoUrl);
        expect(dto.isEmailVerified, isTrue);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, testLastSignInAt);
      });

      test('creates AuthUserDto from Supabase User with minimal fields', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{},
          aud: 'authenticated',
          email: testEmail,
          createdAt: testCreatedAt.toIso8601String(),
          updatedAt: testCreatedAt.toIso8601String(),
        );

        final dto = AuthUserDto.fromSupabaseUser(supabaseUser);

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, isNull);
        expect(dto.photoUrl, isNull);
        expect(dto.isEmailVerified, isFalse);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, isNull);
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

        final dto = AuthUserDto.fromSupabaseUser(supabaseUser);

        expect(dto.email, '');
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
        var dto = AuthUserDto.fromSupabaseUser(supabaseUser);
        expect(dto.displayName, 'Display Name');

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
        dto = AuthUserDto.fromSupabaseUser(supabaseUser);
        expect(dto.displayName, 'Name Field');

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
        dto = AuthUserDto.fromSupabaseUser(supabaseUser);
        expect(dto.displayName, 'Full Name');
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
        var dto = AuthUserDto.fromSupabaseUser(supabaseUser);
        expect(dto.photoUrl, 'avatar.jpg');

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
        dto = AuthUserDto.fromSupabaseUser(supabaseUser);
        expect(dto.photoUrl, 'picture.jpg');
      });
    });

    group('toDomain', () {
      test('converts DTO to domain entity with all fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
        );

        final domainUser = dto.toDomain();

        expect(domainUser.id, testId);
        expect(domainUser.email, testEmail);
        expect(domainUser.displayName, testDisplayName);
        expect(domainUser.photoUrl, testPhotoUrl);
        expect(domainUser.isEmailVerified, isTrue);
        expect(domainUser.createdAt, testCreatedAt);
        expect(domainUser.lastSignInAt, testLastSignInAt);
        // DTO doesn't include metadata, so domain entity should have empty maps
        expect(domainUser.userMetadata, isEmpty);
        expect(domainUser.appMetadata, isEmpty);
      });

      test('converts DTO to domain entity with minimal fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          isEmailVerified: false,
          createdAt: testCreatedAt,
        );

        final domainUser = dto.toDomain();

        expect(domainUser.id, testId);
        expect(domainUser.email, testEmail);
        expect(domainUser.displayName, isNull);
        expect(domainUser.photoUrl, isNull);
        expect(domainUser.isEmailVerified, isFalse);
        expect(domainUser.createdAt, testCreatedAt);
        expect(domainUser.lastSignInAt, isNull);
        expect(domainUser.userMetadata, isEmpty);
        expect(domainUser.appMetadata, isEmpty);
      });

      test('preserves all field values during conversion', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
        );

        final domainUser = dto.toDomain();

        // Verify all fields are preserved exactly
        expect(domainUser.id, dto.id);
        expect(domainUser.email, dto.email);
        expect(domainUser.displayName, dto.displayName);
        expect(domainUser.photoUrl, dto.photoUrl);
        expect(domainUser.isEmailVerified, dto.isEmailVerified);
        expect(domainUser.createdAt, dto.createdAt);
        expect(domainUser.lastSignInAt, dto.lastSignInAt);
      });
    });

    group('fromDomain', () {
      test('creates DTO from domain entity with all fields', () {
        final domainUser = domain.AuthUser(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
          userMetadata: const {'test': 'metadata'},
          appMetadata: const {'app': 'data'},
        );

        final dto = AuthUserDto.fromDomain(domainUser);

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, testDisplayName);
        expect(dto.photoUrl, testPhotoUrl);
        expect(dto.isEmailVerified, isTrue);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, testLastSignInAt);
        // Note: DTO doesn't include metadata fields
      });

      test('creates DTO from domain entity with minimal fields', () {
        final domainUser = domain.AuthUser(
          id: testId,
          email: testEmail,
          isEmailVerified: false,
          createdAt: testCreatedAt,
        );

        final dto = AuthUserDto.fromDomain(domainUser);

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, isNull);
        expect(dto.photoUrl, isNull);
        expect(dto.isEmailVerified, isFalse);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, isNull);
      });
    });

    group('JSON Serialization', () {
      test('converts to and from JSON with all fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: true,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
        );

        final json = dto.toJson();
        final dtoFromJson = AuthUserDto.fromJson(json);

        expect(dtoFromJson.id, dto.id);
        expect(dtoFromJson.email, dto.email);
        expect(dtoFromJson.displayName, dto.displayName);
        expect(dtoFromJson.photoUrl, dto.photoUrl);
        expect(dtoFromJson.isEmailVerified, dto.isEmailVerified);
        expect(dtoFromJson.createdAt, dto.createdAt);
        expect(dtoFromJson.lastSignInAt, dto.lastSignInAt);
      });

      test('converts to and from JSON with minimal fields', () {
        final dto = AuthUserDto(
          id: testId,
          email: testEmail,
          isEmailVerified: false,
          createdAt: testCreatedAt,
        );

        final json = dto.toJson();
        final dtoFromJson = AuthUserDto.fromJson(json);

        expect(dtoFromJson.id, dto.id);
        expect(dtoFromJson.email, dto.email);
        expect(dtoFromJson.displayName, isNull);
        expect(dtoFromJson.photoUrl, isNull);
        expect(dtoFromJson.isEmailVerified, dto.isEmailVerified);
        expect(dtoFromJson.createdAt, dto.createdAt);
        expect(dtoFromJson.lastSignInAt, isNull);
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
        };

        final dto = AuthUserDto.fromJson(json);

        expect(dto.id, testId);
        expect(dto.email, testEmail);
        expect(dto.displayName, isNull);
        expect(dto.photoUrl, isNull);
        expect(dto.isEmailVerified, isFalse);
        expect(dto.createdAt, testCreatedAt);
        expect(dto.lastSignInAt, isNull);
      });
    });

    group('Bidirectional Conversion', () {
      test('Supabase User -> DTO -> Domain -> DTO maintains consistency', () {
        final supabaseUser = supabase.User(
          id: testId,
          appMetadata: const {'provider': 'email'},
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

        // Supabase -> DTO
        final dto1 = AuthUserDto.fromSupabaseUser(supabaseUser);

        // DTO -> Domain
        final domainUser = dto1.toDomain();

        // Domain -> DTO
        final dto2 = AuthUserDto.fromDomain(domainUser);

        // Should be equivalent (except metadata is lost in DTO)
        expect(dto2.id, dto1.id);
        expect(dto2.email, dto1.email);
        expect(dto2.displayName, dto1.displayName);
        expect(dto2.photoUrl, dto1.photoUrl);
        expect(dto2.isEmailVerified, dto1.isEmailVerified);
        expect(dto2.createdAt, dto1.createdAt);
        expect(dto2.lastSignInAt, dto1.lastSignInAt);
      });
    });

    group('Equality', () {
      test('compares equal DTOs', () {
        final dto1 = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );
        final dto2 = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });

      test('compares different DTOs', () {
        final dto1 = AuthUserDto(
          id: testId,
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );
        final dto2 = AuthUserDto(
          id: 'different-id',
          email: testEmail,
          isEmailVerified: true,
          createdAt: testCreatedAt,
        );

        expect(dto1, isNot(equals(dto2)));
        expect(dto1.hashCode, isNot(equals(dto2.hashCode)));
      });
    });

    group('copyWith', () {
      test('copies with modified fields', () {
        final originalDto = AuthUserDto(
          id: testId,
          email: testEmail,
          displayName: testDisplayName,
          photoUrl: testPhotoUrl,
          isEmailVerified: false,
          createdAt: testCreatedAt,
          lastSignInAt: testLastSignInAt,
        );

        final updatedDto = originalDto.copyWith(
          displayName: 'Updated Name',
          isEmailVerified: true,
          photoUrl: 'https://example.com/new-photo.jpg',
        );

        expect(updatedDto.id, originalDto.id); // Unchanged
        expect(updatedDto.email, originalDto.email); // Unchanged
        expect(updatedDto.displayName, 'Updated Name'); // Changed
        expect(
          updatedDto.photoUrl,
          'https://example.com/new-photo.jpg',
        ); // Changed
        expect(updatedDto.isEmailVerified, isTrue); // Changed
        expect(updatedDto.createdAt, originalDto.createdAt); // Unchanged
        expect(updatedDto.lastSignInAt, originalDto.lastSignInAt); // Unchanged
      });
    });
  });
}

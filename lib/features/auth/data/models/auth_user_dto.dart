import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart'
    as domain;

part 'auth_user_dto.freezed.dart';
part 'auth_user_dto.g.dart';

/// Data Transfer Object for AuthUser.
/// Handles mapping between Supabase User objects and domain AuthUser entities.
@freezed
class AuthUserDto with _$AuthUserDto {
  const factory AuthUserDto({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    required DateTime createdAt,
    DateTime? lastSignInAt,
  }) = _AuthUserDto;

  /// Creates an AuthUserDto from a Supabase User object.
  factory AuthUserDto.fromSupabaseUser(User user) {
    return AuthUserDto(
      id: user.id,
      email: user.email ?? '',
      displayName:
          user.userMetadata?['display_name']?.toString() ??
          user.userMetadata?['name']?.toString() ??
          user.userMetadata?['full_name']?.toString(),
      photoUrl:
          user.userMetadata?['avatar_url']?.toString() ??
          user.userMetadata?['picture']?.toString(),
      isEmailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.parse(user.lastSignInAt!)
          : null,
    );
  }

  /// Creates an AuthUserDto from a domain AuthUser entity.
  factory AuthUserDto.fromDomain(domain.AuthUser user) {
    return AuthUserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      createdAt: user.createdAt,
      lastSignInAt: user.lastSignInAt,
    );
  }

  /// Creates an AuthUserDto from JSON.
  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);

  const AuthUserDto._();

  /// Converts this DTO to a domain AuthUser entity.
  domain.AuthUser toDomain() {
    return domain.AuthUser(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }
}

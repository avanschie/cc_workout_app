import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Domain model representing an authenticated user.
///
/// This is a clean domain entity that encapsulates the essential user data
/// needed for authentication state management. It maps from Supabase's User
/// but only includes the fields we actually use in our application.
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    required DateTime createdAt,
    DateTime? lastSignInAt,
    @Default({}) Map<String, dynamic> userMetadata,
    @Default({}) Map<String, dynamic> appMetadata,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  /// Creates an AuthUser from a Supabase User object.
  ///
  /// This factory method handles the mapping from the infrastructure layer
  /// (Supabase User) to our domain entity.
  factory AuthUser.fromSupabaseUser(supabase.User user) {
    return AuthUser(
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
      userMetadata: user.userMetadata ?? {},
      appMetadata: (user.appMetadata as Map<String, dynamic>?) ?? {},
    );
  }
}

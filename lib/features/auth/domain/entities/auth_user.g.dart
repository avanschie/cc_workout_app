// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastSignInAt: json['lastSignInAt'] == null
      ? null
      : DateTime.parse(json['lastSignInAt'] as String),
  userMetadata: json['userMetadata'] as Map<String, dynamic>? ?? const {},
  appMetadata: json['appMetadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'isEmailVerified': instance.isEmailVerified,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastSignInAt': instance.lastSignInAt?.toIso8601String(),
  'userMetadata': instance.userMetadata,
  'appMetadata': instance.appMetadata,
};

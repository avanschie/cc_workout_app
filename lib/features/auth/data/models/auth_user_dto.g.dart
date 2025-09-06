// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthUserDtoImpl _$$AuthUserDtoImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserDtoImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] == null
          ? null
          : DateTime.parse(json['lastSignInAt'] as String),
    );

Map<String, dynamic> _$$AuthUserDtoImplToJson(_$AuthUserDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'isEmailVerified': instance.isEmailVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastSignInAt': instance.lastSignInAt?.toIso8601String(),
    };

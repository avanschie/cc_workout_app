// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthUserDto _$AuthUserDtoFromJson(Map<String, dynamic> json) {
  return _AuthUserDto.fromJson(json);
}

/// @nodoc
mixin _$AuthUserDto {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastSignInAt => throw _privateConstructorUsedError;

  /// Serializes this AuthUserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthUserDtoCopyWith<AuthUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthUserDtoCopyWith<$Res> {
  factory $AuthUserDtoCopyWith(
    AuthUserDto value,
    $Res Function(AuthUserDto) then,
  ) = _$AuthUserDtoCopyWithImpl<$Res, AuthUserDto>;
  @useResult
  $Res call({
    String id,
    String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified,
    DateTime createdAt,
    DateTime? lastSignInAt,
  });
}

/// @nodoc
class _$AuthUserDtoCopyWithImpl<$Res, $Val extends AuthUserDto>
    implements $AuthUserDtoCopyWith<$Res> {
  _$AuthUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? isEmailVerified = null,
    Object? createdAt = null,
    Object? lastSignInAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isEmailVerified: null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastSignInAt: freezed == lastSignInAt
                ? _value.lastSignInAt
                : lastSignInAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthUserDtoImplCopyWith<$Res>
    implements $AuthUserDtoCopyWith<$Res> {
  factory _$$AuthUserDtoImplCopyWith(
    _$AuthUserDtoImpl value,
    $Res Function(_$AuthUserDtoImpl) then,
  ) = __$$AuthUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified,
    DateTime createdAt,
    DateTime? lastSignInAt,
  });
}

/// @nodoc
class __$$AuthUserDtoImplCopyWithImpl<$Res>
    extends _$AuthUserDtoCopyWithImpl<$Res, _$AuthUserDtoImpl>
    implements _$$AuthUserDtoImplCopyWith<$Res> {
  __$$AuthUserDtoImplCopyWithImpl(
    _$AuthUserDtoImpl _value,
    $Res Function(_$AuthUserDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? isEmailVerified = null,
    Object? createdAt = null,
    Object? lastSignInAt = freezed,
  }) {
    return _then(
      _$AuthUserDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isEmailVerified: null == isEmailVerified
            ? _value.isEmailVerified
            : isEmailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastSignInAt: freezed == lastSignInAt
            ? _value.lastSignInAt
            : lastSignInAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthUserDtoImpl extends _AuthUserDto {
  const _$AuthUserDtoImpl({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastSignInAt,
  }) : super._();

  factory _$AuthUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthUserDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final bool isEmailVerified;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastSignInAt;

  @override
  String toString() {
    return 'AuthUserDto(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, isEmailVerified: $isEmailVerified, createdAt: $createdAt, lastSignInAt: $lastSignInAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUserDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastSignInAt, lastSignInAt) ||
                other.lastSignInAt == lastSignInAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    displayName,
    photoUrl,
    isEmailVerified,
    createdAt,
    lastSignInAt,
  );

  /// Create a copy of AuthUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUserDtoImplCopyWith<_$AuthUserDtoImpl> get copyWith =>
      __$$AuthUserDtoImplCopyWithImpl<_$AuthUserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthUserDtoImplToJson(this);
  }
}

abstract class _AuthUserDto extends AuthUserDto {
  const factory _AuthUserDto({
    required final String id,
    required final String email,
    final String? displayName,
    final String? photoUrl,
    required final bool isEmailVerified,
    required final DateTime createdAt,
    final DateTime? lastSignInAt,
  }) = _$AuthUserDtoImpl;
  const _AuthUserDto._() : super._();

  factory _AuthUserDto.fromJson(Map<String, dynamic> json) =
      _$AuthUserDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  bool get isEmailVerified;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastSignInAt;

  /// Create a copy of AuthUserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthUserDtoImplCopyWith<_$AuthUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

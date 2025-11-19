// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rep_max.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RepMax _$RepMaxFromJson(Map<String, dynamic> json) {
  return _RepMax.fromJson(json);
}

/// @nodoc
mixin _$RepMax {
  String get userId => throw _privateConstructorUsedError;
  LiftType get lift => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  DateTime get lastPerformedAt => throw _privateConstructorUsedError;

  /// Serializes this RepMax to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepMax
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepMaxCopyWith<RepMax> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepMaxCopyWith<$Res> {
  factory $RepMaxCopyWith(RepMax value, $Res Function(RepMax) then) =
      _$RepMaxCopyWithImpl<$Res, RepMax>;
  @useResult
  $Res call({
    String userId,
    LiftType lift,
    int reps,
    double weightKg,
    DateTime lastPerformedAt,
  });
}

/// @nodoc
class _$RepMaxCopyWithImpl<$Res, $Val extends RepMax>
    implements $RepMaxCopyWith<$Res> {
  _$RepMaxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepMax
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lift = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? lastPerformedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            lift: null == lift
                ? _value.lift
                : lift // ignore: cast_nullable_to_non_nullable
                      as LiftType,
            reps: null == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int,
            weightKg: null == weightKg
                ? _value.weightKg
                : weightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            lastPerformedAt: null == lastPerformedAt
                ? _value.lastPerformedAt
                : lastPerformedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RepMaxImplCopyWith<$Res> implements $RepMaxCopyWith<$Res> {
  factory _$$RepMaxImplCopyWith(
    _$RepMaxImpl value,
    $Res Function(_$RepMaxImpl) then,
  ) = __$$RepMaxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    LiftType lift,
    int reps,
    double weightKg,
    DateTime lastPerformedAt,
  });
}

/// @nodoc
class __$$RepMaxImplCopyWithImpl<$Res>
    extends _$RepMaxCopyWithImpl<$Res, _$RepMaxImpl>
    implements _$$RepMaxImplCopyWith<$Res> {
  __$$RepMaxImplCopyWithImpl(
    _$RepMaxImpl _value,
    $Res Function(_$RepMaxImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RepMax
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lift = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? lastPerformedAt = null,
  }) {
    return _then(
      _$RepMaxImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        lift: null == lift
            ? _value.lift
            : lift // ignore: cast_nullable_to_non_nullable
                  as LiftType,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int,
        weightKg: null == weightKg
            ? _value.weightKg
            : weightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        lastPerformedAt: null == lastPerformedAt
            ? _value.lastPerformedAt
            : lastPerformedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RepMaxImpl implements _RepMax {
  const _$RepMaxImpl({
    required this.userId,
    required this.lift,
    required this.reps,
    required this.weightKg,
    required this.lastPerformedAt,
  });

  factory _$RepMaxImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepMaxImplFromJson(json);

  @override
  final String userId;
  @override
  final LiftType lift;
  @override
  final int reps;
  @override
  final double weightKg;
  @override
  final DateTime lastPerformedAt;

  @override
  String toString() {
    return 'RepMax(userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, lastPerformedAt: $lastPerformedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepMaxImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lift, lift) || other.lift == lift) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.lastPerformedAt, lastPerformedAt) ||
                other.lastPerformedAt == lastPerformedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, lift, reps, weightKg, lastPerformedAt);

  /// Create a copy of RepMax
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepMaxImplCopyWith<_$RepMaxImpl> get copyWith =>
      __$$RepMaxImplCopyWithImpl<_$RepMaxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepMaxImplToJson(this);
  }
}

abstract class _RepMax implements RepMax {
  const factory _RepMax({
    required final String userId,
    required final LiftType lift,
    required final int reps,
    required final double weightKg,
    required final DateTime lastPerformedAt,
  }) = _$RepMaxImpl;

  factory _RepMax.fromJson(Map<String, dynamic> json) = _$RepMaxImpl.fromJson;

  @override
  String get userId;
  @override
  LiftType get lift;
  @override
  int get reps;
  @override
  double get weightKg;
  @override
  DateTime get lastPerformedAt;

  /// Create a copy of RepMax
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepMaxImplCopyWith<_$RepMaxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

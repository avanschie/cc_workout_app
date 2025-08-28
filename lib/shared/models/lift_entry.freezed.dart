// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lift_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LiftEntry _$LiftEntryFromJson(Map<String, dynamic> json) {
  return _LiftEntry.fromJson(json);
}

/// @nodoc
mixin _$LiftEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  LiftType get lift => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  DateTime get performedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LiftEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiftEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiftEntryCopyWith<LiftEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiftEntryCopyWith<$Res> {
  factory $LiftEntryCopyWith(LiftEntry value, $Res Function(LiftEntry) then) =
      _$LiftEntryCopyWithImpl<$Res, LiftEntry>;
  @useResult
  $Res call({
    String id,
    String userId,
    LiftType lift,
    int reps,
    double weightKg,
    DateTime performedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LiftEntryCopyWithImpl<$Res, $Val extends LiftEntry>
    implements $LiftEntryCopyWith<$Res> {
  _$LiftEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiftEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lift = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? performedAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            performedAt: null == performedAt
                ? _value.performedAt
                : performedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiftEntryImplCopyWith<$Res>
    implements $LiftEntryCopyWith<$Res> {
  factory _$$LiftEntryImplCopyWith(
    _$LiftEntryImpl value,
    $Res Function(_$LiftEntryImpl) then,
  ) = __$$LiftEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    LiftType lift,
    int reps,
    double weightKg,
    DateTime performedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LiftEntryImplCopyWithImpl<$Res>
    extends _$LiftEntryCopyWithImpl<$Res, _$LiftEntryImpl>
    implements _$$LiftEntryImplCopyWith<$Res> {
  __$$LiftEntryImplCopyWithImpl(
    _$LiftEntryImpl _value,
    $Res Function(_$LiftEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiftEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lift = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? performedAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LiftEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        performedAt: null == performedAt
            ? _value.performedAt
            : performedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiftEntryImpl extends _LiftEntry {
  const _$LiftEntryImpl({
    required this.id,
    required this.userId,
    required this.lift,
    required this.reps,
    required this.weightKg,
    required this.performedAt,
    required this.createdAt,
  }) : super._();

  factory _$LiftEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiftEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final LiftType lift;
  @override
  final int reps;
  @override
  final double weightKg;
  @override
  final DateTime performedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LiftEntry(id: $id, userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, performedAt: $performedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiftEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lift, lift) || other.lift == lift) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.performedAt, performedAt) ||
                other.performedAt == performedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    lift,
    reps,
    weightKg,
    performedAt,
    createdAt,
  );

  /// Create a copy of LiftEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiftEntryImplCopyWith<_$LiftEntryImpl> get copyWith =>
      __$$LiftEntryImplCopyWithImpl<_$LiftEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiftEntryImplToJson(this);
  }
}

abstract class _LiftEntry extends LiftEntry {
  const factory _LiftEntry({
    required final String id,
    required final String userId,
    required final LiftType lift,
    required final int reps,
    required final double weightKg,
    required final DateTime performedAt,
    required final DateTime createdAt,
  }) = _$LiftEntryImpl;
  const _LiftEntry._() : super._();

  factory _LiftEntry.fromJson(Map<String, dynamic> json) =
      _$LiftEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  LiftType get lift;
  @override
  int get reps;
  @override
  double get weightKg;
  @override
  DateTime get performedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of LiftEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiftEntryImplCopyWith<_$LiftEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

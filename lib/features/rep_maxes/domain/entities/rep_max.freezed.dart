// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rep_max.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepMax {

 String get userId; LiftType get lift; int get reps; double get weightKg; DateTime get lastPerformedAt;
/// Create a copy of RepMax
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepMaxCopyWith<RepMax> get copyWith => _$RepMaxCopyWithImpl<RepMax>(this as RepMax, _$identity);

  /// Serializes this RepMax to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepMax&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lift, lift) || other.lift == lift)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.lastPerformedAt, lastPerformedAt) || other.lastPerformedAt == lastPerformedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lift,reps,weightKg,lastPerformedAt);

@override
String toString() {
  return 'RepMax(userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, lastPerformedAt: $lastPerformedAt)';
}


}

/// @nodoc
abstract mixin class $RepMaxCopyWith<$Res>  {
  factory $RepMaxCopyWith(RepMax value, $Res Function(RepMax) _then) = _$RepMaxCopyWithImpl;
@useResult
$Res call({
 String userId, LiftType lift, int reps, double weightKg, DateTime lastPerformedAt
});




}
/// @nodoc
class _$RepMaxCopyWithImpl<$Res>
    implements $RepMaxCopyWith<$Res> {
  _$RepMaxCopyWithImpl(this._self, this._then);

  final RepMax _self;
  final $Res Function(RepMax) _then;

/// Create a copy of RepMax
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? lift = null,Object? reps = null,Object? weightKg = null,Object? lastPerformedAt = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lift: null == lift ? _self.lift : lift // ignore: cast_nullable_to_non_nullable
as LiftType,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,lastPerformedAt: null == lastPerformedAt ? _self.lastPerformedAt : lastPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RepMax].
extension RepMaxPatterns on RepMax {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepMax value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepMax() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepMax value)  $default,){
final _that = this;
switch (_that) {
case _RepMax():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepMax value)?  $default,){
final _that = this;
switch (_that) {
case _RepMax() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  LiftType lift,  int reps,  double weightKg,  DateTime lastPerformedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepMax() when $default != null:
return $default(_that.userId,_that.lift,_that.reps,_that.weightKg,_that.lastPerformedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  LiftType lift,  int reps,  double weightKg,  DateTime lastPerformedAt)  $default,) {final _that = this;
switch (_that) {
case _RepMax():
return $default(_that.userId,_that.lift,_that.reps,_that.weightKg,_that.lastPerformedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  LiftType lift,  int reps,  double weightKg,  DateTime lastPerformedAt)?  $default,) {final _that = this;
switch (_that) {
case _RepMax() when $default != null:
return $default(_that.userId,_that.lift,_that.reps,_that.weightKg,_that.lastPerformedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepMax implements RepMax {
  const _RepMax({required this.userId, required this.lift, required this.reps, required this.weightKg, required this.lastPerformedAt});
  factory _RepMax.fromJson(Map<String, dynamic> json) => _$RepMaxFromJson(json);

@override final  String userId;
@override final  LiftType lift;
@override final  int reps;
@override final  double weightKg;
@override final  DateTime lastPerformedAt;

/// Create a copy of RepMax
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepMaxCopyWith<_RepMax> get copyWith => __$RepMaxCopyWithImpl<_RepMax>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepMaxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepMax&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lift, lift) || other.lift == lift)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.lastPerformedAt, lastPerformedAt) || other.lastPerformedAt == lastPerformedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lift,reps,weightKg,lastPerformedAt);

@override
String toString() {
  return 'RepMax(userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, lastPerformedAt: $lastPerformedAt)';
}


}

/// @nodoc
abstract mixin class _$RepMaxCopyWith<$Res> implements $RepMaxCopyWith<$Res> {
  factory _$RepMaxCopyWith(_RepMax value, $Res Function(_RepMax) _then) = __$RepMaxCopyWithImpl;
@override @useResult
$Res call({
 String userId, LiftType lift, int reps, double weightKg, DateTime lastPerformedAt
});




}
/// @nodoc
class __$RepMaxCopyWithImpl<$Res>
    implements _$RepMaxCopyWith<$Res> {
  __$RepMaxCopyWithImpl(this._self, this._then);

  final _RepMax _self;
  final $Res Function(_RepMax) _then;

/// Create a copy of RepMax
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? lift = null,Object? reps = null,Object? weightKg = null,Object? lastPerformedAt = null,}) {
  return _then(_RepMax(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lift: null == lift ? _self.lift : lift // ignore: cast_nullable_to_non_nullable
as LiftType,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,lastPerformedAt: null == lastPerformedAt ? _self.lastPerformedAt : lastPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

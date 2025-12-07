// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lift_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiftEntry {

 String get id; String get userId; LiftType get lift; int get reps; double get weightKg; DateTime get performedAt; DateTime get createdAt;
/// Create a copy of LiftEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiftEntryCopyWith<LiftEntry> get copyWith => _$LiftEntryCopyWithImpl<LiftEntry>(this as LiftEntry, _$identity);

  /// Serializes this LiftEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiftEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lift, lift) || other.lift == lift)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,lift,reps,weightKg,performedAt,createdAt);

@override
String toString() {
  return 'LiftEntry(id: $id, userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, performedAt: $performedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LiftEntryCopyWith<$Res>  {
  factory $LiftEntryCopyWith(LiftEntry value, $Res Function(LiftEntry) _then) = _$LiftEntryCopyWithImpl;
@useResult
$Res call({
 String id, String userId, LiftType lift, int reps, double weightKg, DateTime performedAt, DateTime createdAt
});




}
/// @nodoc
class _$LiftEntryCopyWithImpl<$Res>
    implements $LiftEntryCopyWith<$Res> {
  _$LiftEntryCopyWithImpl(this._self, this._then);

  final LiftEntry _self;
  final $Res Function(LiftEntry) _then;

/// Create a copy of LiftEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? lift = null,Object? reps = null,Object? weightKg = null,Object? performedAt = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lift: null == lift ? _self.lift : lift // ignore: cast_nullable_to_non_nullable
as LiftType,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LiftEntry].
extension LiftEntryPatterns on LiftEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiftEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiftEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiftEntry value)  $default,){
final _that = this;
switch (_that) {
case _LiftEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiftEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LiftEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  LiftType lift,  int reps,  double weightKg,  DateTime performedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiftEntry() when $default != null:
return $default(_that.id,_that.userId,_that.lift,_that.reps,_that.weightKg,_that.performedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  LiftType lift,  int reps,  double weightKg,  DateTime performedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LiftEntry():
return $default(_that.id,_that.userId,_that.lift,_that.reps,_that.weightKg,_that.performedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  LiftType lift,  int reps,  double weightKg,  DateTime performedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LiftEntry() when $default != null:
return $default(_that.id,_that.userId,_that.lift,_that.reps,_that.weightKg,_that.performedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiftEntry extends LiftEntry {
  const _LiftEntry({required this.id, required this.userId, required this.lift, required this.reps, required this.weightKg, required this.performedAt, required this.createdAt}): super._();
  factory _LiftEntry.fromJson(Map<String, dynamic> json) => _$LiftEntryFromJson(json);

@override final  String id;
@override final  String userId;
@override final  LiftType lift;
@override final  int reps;
@override final  double weightKg;
@override final  DateTime performedAt;
@override final  DateTime createdAt;

/// Create a copy of LiftEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiftEntryCopyWith<_LiftEntry> get copyWith => __$LiftEntryCopyWithImpl<_LiftEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiftEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiftEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lift, lift) || other.lift == lift)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,lift,reps,weightKg,performedAt,createdAt);

@override
String toString() {
  return 'LiftEntry(id: $id, userId: $userId, lift: $lift, reps: $reps, weightKg: $weightKg, performedAt: $performedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LiftEntryCopyWith<$Res> implements $LiftEntryCopyWith<$Res> {
  factory _$LiftEntryCopyWith(_LiftEntry value, $Res Function(_LiftEntry) _then) = __$LiftEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, LiftType lift, int reps, double weightKg, DateTime performedAt, DateTime createdAt
});




}
/// @nodoc
class __$LiftEntryCopyWithImpl<$Res>
    implements _$LiftEntryCopyWith<$Res> {
  __$LiftEntryCopyWithImpl(this._self, this._then);

  final _LiftEntry _self;
  final $Res Function(_LiftEntry) _then;

/// Create a copy of LiftEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? lift = null,Object? reps = null,Object? weightKg = null,Object? performedAt = null,Object? createdAt = null,}) {
  return _then(_LiftEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lift: null == lift ? _self.lift : lift // ignore: cast_nullable_to_non_nullable
as LiftType,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

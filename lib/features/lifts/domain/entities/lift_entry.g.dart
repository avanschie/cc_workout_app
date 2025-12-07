// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lift_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiftEntry _$LiftEntryFromJson(Map<String, dynamic> json) => _LiftEntry(
  id: json['id'] as String,
  userId: json['userId'] as String,
  lift: $enumDecode(_$LiftTypeEnumMap, json['lift']),
  reps: (json['reps'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  performedAt: DateTime.parse(json['performedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$LiftEntryToJson(_LiftEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'lift': _$LiftTypeEnumMap[instance.lift]!,
      'reps': instance.reps,
      'weightKg': instance.weightKg,
      'performedAt': instance.performedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LiftTypeEnumMap = {
  LiftType.squat: 'squat',
  LiftType.bench: 'bench',
  LiftType.deadlift: 'deadlift',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_max.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepMaxImpl _$$RepMaxImplFromJson(Map<String, dynamic> json) => _$RepMaxImpl(
  userId: json['userId'] as String,
  lift: $enumDecode(_$LiftTypeEnumMap, json['lift']),
  reps: (json['reps'] as num).toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  lastPerformedAt: DateTime.parse(json['lastPerformedAt'] as String),
);

Map<String, dynamic> _$$RepMaxImplToJson(_$RepMaxImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lift': _$LiftTypeEnumMap[instance.lift]!,
      'reps': instance.reps,
      'weightKg': instance.weightKg,
      'lastPerformedAt': instance.lastPerformedAt.toIso8601String(),
    };

const _$LiftTypeEnumMap = {
  LiftType.squat: 'squat',
  LiftType.bench: 'bench',
  LiftType.deadlift: 'deadlift',
};

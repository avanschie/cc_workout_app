enum LiftType {
  squat('squat'),
  bench('bench'),
  deadlift('deadlift');

  const LiftType(this.value);

  final String value;

  static LiftType fromString(String value) {
    return LiftType.values.firstWhere(
      (lift) => lift.value == value,
      orElse: () => throw ArgumentError('Invalid lift type: $value'),
    );
  }

  String get displayName {
    switch (this) {
      case LiftType.squat:
        return 'Squat';
      case LiftType.bench:
        return 'Bench Press';
      case LiftType.deadlift:
        return 'Deadlift';
    }
  }
}

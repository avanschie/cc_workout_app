import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('LiftType', () {
    test('should have correct values', () {
      expect(LiftType.squat.value, equals('squat'));
      expect(LiftType.bench.value, equals('bench'));
      expect(LiftType.deadlift.value, equals('deadlift'));
    });

    test('should have correct display names', () {
      expect(LiftType.squat.displayName, equals('Squat'));
      expect(LiftType.bench.displayName, equals('Bench Press'));
      expect(LiftType.deadlift.displayName, equals('Deadlift'));
    });

    group('fromString', () {
      test('should return correct LiftType for valid strings', () {
        expect(LiftType.fromString('squat'), equals(LiftType.squat));
        expect(LiftType.fromString('bench'), equals(LiftType.bench));
        expect(LiftType.fromString('deadlift'), equals(LiftType.deadlift));
      });

      test('should throw ArgumentError for invalid string', () {
        expect(
          () => LiftType.fromString('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError with correct message', () {
        expect(
          () => LiftType.fromString('invalid'),
          throwsA(
            predicate(
              (e) =>
                  e is ArgumentError &&
                  e.message == 'Invalid lift type: invalid',
            ),
          ),
        );
      });
    });

    test('should have all three lift types in values', () {
      expect(LiftType.values, hasLength(3));
      expect(LiftType.values, contains(LiftType.squat));
      expect(LiftType.values, contains(LiftType.bench));
      expect(LiftType.values, contains(LiftType.deadlift));
    });
  });
}

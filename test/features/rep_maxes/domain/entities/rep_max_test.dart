import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/rep_maxes/domain/entities/rep_max.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('RepMax', () {
    final validRepMax = RepMax(
      userId: 'user-id',
      lift: LiftType.deadlift,
      reps: 1,
      weightKg: 200.0,
      lastPerformedAt: DateTime(2023, 12, 1),
    );

    group('creation', () {
      test('should create RepMax with valid data', () {
        expect(validRepMax.userId, equals('user-id'));
        expect(validRepMax.lift, equals(LiftType.deadlift));
        expect(validRepMax.reps, equals(1));
        expect(validRepMax.weightKg, equals(200.0));
        expect(validRepMax.lastPerformedAt, equals(DateTime(2023, 12, 1)));
      });
    });

    group('fromSupabaseRow', () {
      test('should create RepMax from valid Supabase row', () {
        final row = {
          'user_id': 'user-123',
          'lift': 'bench',
          'reps': 5,
          'weight_kg': 120.5,
          'performed_at': '2023-11-15T14:30:00.000Z',
        };

        final repMax = RepMax.fromSupabaseRow(row);

        expect(repMax.userId, equals('user-123'));
        expect(repMax.lift, equals(LiftType.bench));
        expect(repMax.reps, equals(5));
        expect(repMax.weightKg, equals(120.5));
        expect(
          repMax.lastPerformedAt,
          equals(DateTime.parse('2023-11-15T14:30:00.000Z')),
        );
      });

      test('should handle integer weight from Supabase', () {
        final row = {
          'user_id': 'user-456',
          'lift': 'squat',
          'reps': 3,
          'weight_kg': 150, // Integer instead of double
          'performed_at': '2023-10-20T09:15:00.000Z',
        };

        final repMax = RepMax.fromSupabaseRow(row);
        expect(repMax.weightKg, equals(150.0));
        expect(repMax.lift, equals(LiftType.squat));
      });

      test('should handle all lift types', () {
        final liftTypes = [
          ('squat', LiftType.squat),
          ('bench', LiftType.bench),
          ('deadlift', LiftType.deadlift),
        ];

        for (final (liftValue, expectedLiftType) in liftTypes) {
          final row = {
            'user_id': 'user-789',
            'lift': liftValue,
            'reps': 1,
            'weight_kg': 100.0,
            'performed_at': '2023-12-01T12:00:00.000Z',
          };

          final repMax = RepMax.fromSupabaseRow(row);
          expect(repMax.lift, equals(expectedLiftType));
        }
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final repMax1 = validRepMax;
        final repMax2 = RepMax(
          userId: 'user-id',
          lift: LiftType.deadlift,
          reps: 1,
          weightKg: 200.0,
          lastPerformedAt: DateTime(2023, 12, 1),
        );

        expect(repMax1, equals(repMax2));
        expect(repMax1.hashCode, equals(repMax2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final repMax1 = validRepMax;
        final repMax2 = validRepMax.copyWith(weightKg: 210.0);

        expect(repMax1, isNot(equals(repMax2)));
      });

      test('should not be equal when userId differs', () {
        final repMax1 = validRepMax;
        final repMax2 = validRepMax.copyWith(userId: 'different-user');

        expect(repMax1, isNot(equals(repMax2)));
      });

      test('should not be equal when lift type differs', () {
        final repMax1 = validRepMax;
        final repMax2 = validRepMax.copyWith(lift: LiftType.squat);

        expect(repMax1, isNot(equals(repMax2)));
      });

      test('should not be equal when reps differ', () {
        final repMax1 = validRepMax;
        final repMax2 = validRepMax.copyWith(reps: 5);

        expect(repMax1, isNot(equals(repMax2)));
      });
    });

    group('immutability', () {
      test('should be immutable via copyWith', () {
        final original = validRepMax;
        final modified = original.copyWith(weightKg: 250.0);

        expect(original.weightKg, equals(200.0));
        expect(modified.weightKg, equals(250.0));
        expect(original, isNot(equals(modified)));
      });
    });
  });
}

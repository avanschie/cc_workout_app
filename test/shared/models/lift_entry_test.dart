import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('LiftEntry', () {
    final validLiftEntry = LiftEntry(
      id: 'test-id',
      userId: 'user-id',
      lift: LiftType.squat,
      reps: 5,
      weightKg: 100.0,
      performedAt: DateTime(2023, 12, 1),
      createdAt: DateTime(2023, 12, 1, 10, 0),
    );

    group('creation', () {
      test('should create LiftEntry with valid data', () {
        expect(validLiftEntry.id, equals('test-id'));
        expect(validLiftEntry.userId, equals('user-id'));
        expect(validLiftEntry.lift, equals(LiftType.squat));
        expect(validLiftEntry.reps, equals(5));
        expect(validLiftEntry.weightKg, equals(100.0));
        expect(validLiftEntry.performedAt, equals(DateTime(2023, 12, 1)));
        expect(validLiftEntry.createdAt, equals(DateTime(2023, 12, 1, 10, 0)));
      });
    });

    group('fromSupabaseRow', () {
      test('should create LiftEntry from valid Supabase row', () {
        final row = {
          'id': 'test-id',
          'user_id': 'user-id',
          'lift': 'squat',
          'reps': 5,
          'weight_kg': 100.5,
          'performed_at': '2023-12-01',
          'created_at': '2023-12-01T10:00:00.000Z',
        };

        final liftEntry = LiftEntry.fromSupabaseRow(row);

        expect(liftEntry.id, equals('test-id'));
        expect(liftEntry.userId, equals('user-id'));
        expect(liftEntry.lift, equals(LiftType.squat));
        expect(liftEntry.reps, equals(5));
        expect(liftEntry.weightKg, equals(100.5));
        expect(liftEntry.performedAt, equals(DateTime.parse('2023-12-01')));
        expect(
          liftEntry.createdAt,
          equals(DateTime.parse('2023-12-01T10:00:00.000Z')),
        );
      });

      test('should handle integer weight from Supabase', () {
        final row = {
          'id': 'test-id',
          'user_id': 'user-id',
          'lift': 'bench',
          'reps': 3,
          'weight_kg': 80, // Integer instead of double
          'performed_at': '2023-12-01',
          'created_at': '2023-12-01T10:00:00.000Z',
        };

        final liftEntry = LiftEntry.fromSupabaseRow(row);
        expect(liftEntry.weightKg, equals(80.0));
      });
    });

    group('toSupabaseRow', () {
      test('should convert to valid Supabase row format', () {
        final row = validLiftEntry.toSupabaseRow();

        expect(row['id'], equals('test-id'));
        expect(row['user_id'], equals('user-id'));
        expect(row['lift'], equals('squat'));
        expect(row['reps'], equals(5));
        expect(row['weight_kg'], equals(100.0));
        expect(row['performed_at'], equals('2023-12-01'));
        expect(row['created_at'], equals('2023-12-01T10:00:00.000'));
      });

      test('should format date correctly for Supabase', () {
        final liftEntry = validLiftEntry.copyWith(
          performedAt: DateTime(2023, 12, 15, 14, 30, 45),
        );

        final row = liftEntry.toSupabaseRow();
        expect(row['performed_at'], equals('2023-12-15'));
      });
    });

    group('validation', () {
      group('validateReps', () {
        test('should return null for valid reps', () {
          for (int reps = 1; reps <= 10; reps++) {
            final entry = validLiftEntry.copyWith(reps: reps);
            expect(entry.validateReps(), isNull);
          }
        });

        test('should return error for reps below minimum', () {
          final entry = validLiftEntry.copyWith(reps: 0);
          expect(entry.validateReps(), equals('Reps must be between 1 and 10'));
        });

        test('should return error for reps above maximum', () {
          final entry = validLiftEntry.copyWith(reps: 11);
          expect(entry.validateReps(), equals('Reps must be between 1 and 10'));
        });
      });

      group('validateWeight', () {
        test('should return null for valid weight', () {
          final entry = validLiftEntry.copyWith(weightKg: 50.5);
          expect(entry.validateWeight(), isNull);
        });

        test('should return error for zero weight', () {
          final entry = validLiftEntry.copyWith(weightKg: 0.0);
          expect(
            entry.validateWeight(),
            equals('Weight must be greater than 0.0 kg'),
          );
        });

        test('should return error for negative weight', () {
          final entry = validLiftEntry.copyWith(weightKg: -10.0);
          expect(
            entry.validateWeight(),
            equals('Weight must be greater than 0.0 kg'),
          );
        });

        test('should return error for weight exceeding maximum', () {
          final entry = validLiftEntry.copyWith(weightKg: 1001.0);
          expect(
            entry.validateWeight(),
            equals('Weight cannot exceed 1000.0 kg'),
          );
        });
      });

      group('validateDate', () {
        test('should return null for today', () {
          final today = DateTime.now();
          final entry = validLiftEntry.copyWith(performedAt: today);
          expect(entry.validateDate(), isNull);
        });

        test('should return null for past date', () {
          final pastDate = DateTime.now().subtract(Duration(days: 5));
          final entry = validLiftEntry.copyWith(performedAt: pastDate);
          expect(entry.validateDate(), isNull);
        });

        test('should return error for future date', () {
          final futureDate = DateTime.now().add(Duration(days: 1));
          final entry = validLiftEntry.copyWith(performedAt: futureDate);
          expect(entry.validateDate(), equals('Date cannot be in the future'));
        });
      });

      group('isValid', () {
        test('should return true for valid entry', () {
          expect(validLiftEntry.isValid, isTrue);
        });

        test('should return false for invalid reps', () {
          final entry = validLiftEntry.copyWith(reps: 0);
          expect(entry.isValid, isFalse);
        });

        test('should return false for invalid weight', () {
          final entry = validLiftEntry.copyWith(weightKg: 0.0);
          expect(entry.isValid, isFalse);
        });

        test('should return false for invalid date', () {
          final futureDate = DateTime.now().add(Duration(days: 1));
          final entry = validLiftEntry.copyWith(performedAt: futureDate);
          expect(entry.isValid, isFalse);
        });
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final entry1 = validLiftEntry;
        final entry2 = LiftEntry(
          id: 'test-id',
          userId: 'user-id',
          lift: LiftType.squat,
          reps: 5,
          weightKg: 100.0,
          performedAt: DateTime(2023, 12, 1),
          createdAt: DateTime(2023, 12, 1, 10, 0),
        );

        expect(entry1, equals(entry2));
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final entry1 = validLiftEntry;
        final entry2 = validLiftEntry.copyWith(weightKg: 110.0);

        expect(entry1, isNot(equals(entry2)));
      });
    });
  });
}

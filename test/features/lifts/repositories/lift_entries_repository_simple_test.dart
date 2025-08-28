import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/lifts/repositories/lift_entries_repository.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('LiftEntriesRepositoryException', () {
    test('should create exception with message', () {
      const exception = LiftEntriesRepositoryException('Test message');

      expect(exception.message, equals('Test message'));
      expect(
        exception.toString(),
        equals('LiftEntriesRepositoryException: Test message'),
      );
    });

    test('should be throwable', () {
      expect(
        () => throw LiftEntriesRepositoryException('Test error'),
        throwsA(isA<LiftEntriesRepositoryException>()),
      );
    });
  });

  group('LiftEntry validation in repository context', () {
    final validLiftEntry = LiftEntry(
      id: 'test-id',
      userId: 'user-id',
      lift: LiftType.squat,
      reps: 5,
      weightKg: 100.0,
      performedAt: DateTime(2023, 12, 1),
      createdAt: DateTime(2023, 12, 1, 10, 0),
    );

    test('should identify valid lift entry', () {
      expect(validLiftEntry.isValid, isTrue);
    });

    test('should identify invalid lift entry with bad reps', () {
      final invalidEntry = validLiftEntry.copyWith(reps: 0);
      expect(invalidEntry.isValid, isFalse);
    });

    test('should identify invalid lift entry with bad weight', () {
      final invalidEntry = validLiftEntry.copyWith(weightKg: -10.0);
      expect(invalidEntry.isValid, isFalse);
    });

    test('should handle Supabase row conversion correctly', () {
      final row = {
        'id': 'test-id',
        'user_id': 'user-id',
        'lift': 'deadlift',
        'reps': 3,
        'weight_kg': 150.5,
        'performed_at': '2023-12-01',
        'created_at': '2023-12-01T10:00:00.000Z',
      };

      final liftEntry = LiftEntry.fromSupabaseRow(row);
      expect(liftEntry.lift, equals(LiftType.deadlift));
      expect(liftEntry.reps, equals(3));
      expect(liftEntry.weightKg, equals(150.5));

      final convertedBack = liftEntry.toSupabaseRow();
      expect(convertedBack['lift'], equals('deadlift'));
      expect(convertedBack['reps'], equals(3));
      expect(convertedBack['weight_kg'], equals(150.5));
    });
  });
}

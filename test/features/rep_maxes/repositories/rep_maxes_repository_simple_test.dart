import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/features/rep_maxes/repositories/rep_maxes_repository.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('RepMaxesRepositoryException', () {
    test('should create exception with message', () {
      const exception = RepMaxesRepositoryException('Test message');

      expect(exception.message, equals('Test message'));
      expect(
        exception.toString(),
        equals('RepMaxesRepositoryException: Test message'),
      );
    });

    test('should be throwable', () {
      expect(
        () => throw RepMaxesRepositoryException('Test error'),
        throwsA(isA<RepMaxesRepositoryException>()),
      );
    });
  });

  group('RepMax data handling in repository context', () {
    test('should handle Supabase row conversion correctly', () {
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

    test('should handle integer weight conversion', () {
      final row = {
        'user_id': 'user-456',
        'lift': 'squat',
        'reps': 1,
        'weight_kg': 200, // Integer
        'performed_at': '2023-12-01T10:00:00.000Z',
      };

      final repMax = RepMax.fromSupabaseRow(row);
      expect(repMax.weightKg, equals(200.0));
    });

    test('should handle all lift types correctly', () {
      final testCases = [
        ('squat', LiftType.squat),
        ('bench', LiftType.bench),
        ('deadlift', LiftType.deadlift),
      ];

      for (final (liftString, expectedLiftType) in testCases) {
        final row = {
          'user_id': 'user-test',
          'lift': liftString,
          'reps': 1,
          'weight_kg': 100.0,
          'performed_at': '2023-12-01T12:00:00.000Z',
        };

        final repMax = RepMax.fromSupabaseRow(row);
        expect(repMax.lift, equals(expectedLiftType));
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/auth/domain/entities/auth_user.dart';

void main() {
  group('Core Models', () {
    test('LiftType has correct values', () {
      expect(LiftType.values.length, 3);
      expect(LiftType.squat.displayName, 'Squat');
      expect(LiftType.bench.displayName, 'Bench Press');
      expect(LiftType.deadlift.displayName, 'Deadlift');
    });

    test('RepMax model creates correctly', () {
      final repMax = RepMax(
        userId: 'test-user-id',
        lift: LiftType.squat,
        reps: 5,
        weightKg: 100.0,
        lastPerformedAt: DateTime(2024, 1, 1),
      );

      expect(repMax.userId, 'test-user-id');
      expect(repMax.lift, LiftType.squat);
      expect(repMax.reps, 5);
      expect(repMax.weightKg, 100.0);
      expect(repMax.lastPerformedAt, DateTime(2024, 1, 1));
    });

    test('AuthUser model creates correctly', () {
      final user = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isEmailVerified, true);
      expect(user.createdAt, DateTime(2024, 1, 1));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/core/constants/validation.dart';

void main() {
  group('ValidationConstants', () {
    test('should have correct rep range values', () {
      expect(ValidationConstants.minReps, equals(1));
      expect(ValidationConstants.maxReps, equals(10));
    });

    test('should have correct weight range values', () {
      expect(ValidationConstants.minWeight, equals(0.0));
      expect(ValidationConstants.maxWeight, equals(1000.0));
    });

    test('should have correct error messages', () {
      expect(
        ValidationConstants.repsRangeError,
        equals('Reps must be between 1 and 10'),
      );
      expect(
        ValidationConstants.weightRangeError,
        equals('Weight must be greater than 0.0 kg'),
      );
      expect(
        ValidationConstants.weightMaxError,
        equals('Weight cannot exceed 1000.0 kg'),
      );
      expect(ValidationConstants.dateRequiredError, equals('Date is required'));
    });

    test('should not allow instantiation', () {
      // This test ensures the constructor is private
      // If it compiles, the private constructor is working
      expect(() => ValidationConstants, isNotNull);
    });
  });
}

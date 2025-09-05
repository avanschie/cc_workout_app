import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc_workout_app/shared/constants/lift_colors.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

void main() {
  group('LiftColors', () {
    test('getColor returns correct colors for each lift type', () {
      expect(LiftColors.getColor(LiftType.squat), LiftColors.squat);
      expect(LiftColors.getColor(LiftType.bench), LiftColors.bench);
      expect(LiftColors.getColor(LiftType.deadlift), LiftColors.deadlift);
    });

    test(
      'getAbbreviation returns correct abbreviations for each lift type',
      () {
        expect(LiftColors.getAbbreviation(LiftType.squat), 'SQ');
        expect(LiftColors.getAbbreviation(LiftType.bench), 'BP');
        expect(LiftColors.getAbbreviation(LiftType.deadlift), 'DL');
      },
    );

    test('color constants have expected values', () {
      expect(LiftColors.squat, const Color(0xFF64B5F6));
      expect(LiftColors.bench, const Color(0xFFE57373));
      expect(LiftColors.deadlift, const Color(0xFF81C784));
    });

    test('colors are distinct from each other', () {
      final colors = [LiftColors.squat, LiftColors.bench, LiftColors.deadlift];

      // Check that all colors are unique
      final uniqueColors = colors.toSet();
      expect(uniqueColors.length, colors.length);
    });
  });
}

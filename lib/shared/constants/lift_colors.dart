import 'package:flutter/material.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

class LiftColors {
  static const Color squat = Color(0xFF64B5F6); // Colors.blue.shade300
  static const Color bench = Color(0xFFE57373); // Colors.red.shade300
  static const Color deadlift = Color(0xFF81C784); // Colors.green.shade300

  static Color getColor(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return squat;
      case LiftType.bench:
        return bench;
      case LiftType.deadlift:
        return deadlift;
    }
  }

  static String getAbbreviation(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return 'SQ';
      case LiftType.bench:
        return 'BP';
      case LiftType.deadlift:
        return 'DL';
    }
  }
}

import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/core/constants/validation.dart';

/// Centralized validation logic for lift forms
class LiftFormValidator {
  /// Validates lift type selection
  static String? validateLiftType(LiftType? liftType) {
    if (liftType == null) {
      return 'Lift type is required';
    }
    return null;
  }

  /// Validates reps input from text field
  static ({int? reps, String? error}) validateRepsText(String repsText) {
    if (repsText.isEmpty) {
      return (reps: null, error: 'Reps is required');
    }

    // Handle leading/trailing whitespace
    final cleanText = repsText.trim();
    if (cleanText.isEmpty) {
      return (reps: null, error: 'Reps is required');
    }

    final reps = int.tryParse(cleanText);
    if (reps == null) {
      return (reps: null, error: 'Please enter a valid whole number');
    }

    String? error;
    if (reps < ValidationConstants.minReps) {
      error = 'Minimum ${ValidationConstants.minReps} rep required';
    } else if (reps > ValidationConstants.maxReps) {
      error = 'Maximum ${ValidationConstants.maxReps} reps allowed';
    }

    return (reps: reps, error: error);
  }

  /// Validates reps value directly
  static String? validateReps(int? reps) {
    if (reps == null) {
      return 'Reps is required';
    }

    if (reps < ValidationConstants.minReps) {
      return 'Minimum ${ValidationConstants.minReps} rep required';
    } else if (reps > ValidationConstants.maxReps) {
      return 'Maximum ${ValidationConstants.maxReps} reps allowed';
    }

    return null;
  }

  /// Validates weight input from text field
  static ({double? weight, String? error}) validateWeightText(
    String weightText,
  ) {
    if (weightText.isEmpty) {
      return (weight: null, error: 'Weight is required');
    }

    // Handle leading/trailing whitespace and common formatting
    final cleanText = weightText.trim().replaceAll(',', '.');
    if (cleanText.isEmpty) {
      return (weight: null, error: 'Weight is required');
    }

    final weight = double.tryParse(cleanText);
    if (weight == null) {
      return (
        weight: null,
        error: 'Please enter a valid number (e.g., 100 or 100.5)',
      );
    }

    String? error;
    if (weight <= ValidationConstants.minWeight) {
      error = 'Weight must be greater than ${ValidationConstants.minWeight} kg';
    } else if (weight > ValidationConstants.maxWeight) {
      error = 'Weight cannot exceed ${ValidationConstants.maxWeight} kg';
    } else if (_hasMoreThanTwoDecimals(weight)) {
      error = 'Weight can have at most 2 decimal places';
    }

    return (weight: weight, error: error);
  }

  /// Validates weight value directly
  static String? validateWeight(double? weight) {
    if (weight == null) {
      return 'Weight is required';
    }

    if (weight <= ValidationConstants.minWeight) {
      return 'Weight must be greater than ${ValidationConstants.minWeight} kg';
    } else if (weight > ValidationConstants.maxWeight) {
      return 'Weight cannot exceed ${ValidationConstants.maxWeight} kg';
    } else if (_hasMoreThanTwoDecimals(weight)) {
      return 'Weight can have at most 2 decimal places';
    }

    return null;
  }

  /// Validates date selection
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return ValidationConstants.dateRequiredError;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final performedDate = DateTime(date.year, date.month, date.day);

    if (performedDate.isAfter(today)) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// Helper method to check if double has more than 2 decimal places
  static bool _hasMoreThanTwoDecimals(double value) {
    final parts = value.toString().split('.');
    return parts.length > 1 && parts[1].length > 2;
  }
}

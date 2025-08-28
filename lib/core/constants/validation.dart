class ValidationConstants {
  ValidationConstants._();

  static const int minReps = 1;
  static const int maxReps = 10;
  static const double minWeight = 0.0;
  static const double maxWeight = 1000.0; // 1000kg reasonable max

  static const String repsRangeError =
      'Reps must be between $minReps and $maxReps';
  static const String weightRangeError =
      'Weight must be greater than $minWeight kg';
  static const String weightMaxError = 'Weight cannot exceed $maxWeight kg';
  static const String dateRequiredError = 'Date is required';
}

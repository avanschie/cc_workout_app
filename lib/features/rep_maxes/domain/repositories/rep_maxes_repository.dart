import 'package:cc_workout_app/features/rep_maxes/domain/entities/rep_max.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

abstract class RepMaxesRepository {
  Future<List<RepMax>> getAllRepMaxes();
  Future<List<RepMax>> getRepMaxesByLiftType(LiftType liftType);
  Future<RepMax?> getRepMaxForLiftAndReps(LiftType liftType, int reps);
}

class RepMaxesRepositoryException implements Exception {
  const RepMaxesRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'RepMaxesRepositoryException: $message';
}

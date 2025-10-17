import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/repositories/rep_maxes_repository.dart';

class RepMaxCalculationService {
  const RepMaxCalculationService(this._repository);

  final RepMaxesRepository _repository;

  Future<List<RepMax>> calculateAllRepMaxes() async {
    return await _repository.getAllRepMaxes();
  }

  Future<Map<LiftType, List<RepMax>>> calculateRepMaxesByLift() async {
    final allRepMaxes = await _repository.getAllRepMaxes();

    final Map<LiftType, List<RepMax>> result = {};

    for (final liftType in LiftType.values) {
      result[liftType] =
          allRepMaxes.where((repMax) => repMax.lift == liftType).toList()
            ..sort((a, b) => a.reps.compareTo(b.reps));
    }

    return result;
  }

  Future<List<RepMax>> calculateRepMaxesForLift(LiftType liftType) async {
    return await _repository.getRepMaxesByLiftType(liftType);
  }

  Future<RepMax?> getRepMaxForLiftAndReps(LiftType liftType, int reps) async {
    if (reps < 1 || reps > 10) {
      throw ArgumentError('Reps must be between 1 and 10, got: $reps');
    }

    return await _repository.getRepMaxForLiftAndReps(liftType, reps);
  }

  Map<int, RepMax> _groupByReps(List<RepMax> repMaxes) {
    final Map<int, RepMax> result = {};

    for (final repMax in repMaxes) {
      if (repMax.reps >= 1 && repMax.reps <= 10) {
        result[repMax.reps] = repMax;
      }
    }

    return result;
  }

  Future<Map<int, RepMax>> getRepMaxTableForLift(LiftType liftType) async {
    final repMaxes = await calculateRepMaxesForLift(liftType);
    return _groupByReps(repMaxes);
  }

  Future<Map<LiftType, Map<int, RepMax>>> getFullRepMaxTable() async {
    final repMaxesByLift = await calculateRepMaxesByLift();

    final Map<LiftType, Map<int, RepMax>> result = {};

    for (final entry in repMaxesByLift.entries) {
      result[entry.key] = _groupByReps(entry.value);
    }

    return result;
  }
}

class RepMaxCalculationServiceException implements Exception {
  const RepMaxCalculationServiceException(this.message);

  final String message;

  @override
  String toString() => 'RepMaxCalculationServiceException: $message';
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/core/utils/retry_utils.dart';
import 'package:cc_workout_app/core/utils/error_handler.dart';

abstract class RepMaxesRepository {
  Future<List<RepMax>> getAllRepMaxes();
  Future<List<RepMax>> getRepMaxesByLiftType(LiftType liftType);
  Future<RepMax?> getRepMaxForLiftAndReps(LiftType liftType, int reps);
}

class SupabaseRepMaxesRepository implements RepMaxesRepository {
  final SupabaseClient _supabase;

  SupabaseRepMaxesRepository(this._supabase);

  @override
  Future<List<RepMax>> getAllRepMaxes() async {
    return RetryUtils.retry(() async {
      try {
        final response = await _supabase.from('rep_maxes').select();

        return response
            .map<RepMax>((row) => RepMax.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw RepMaxesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<List<RepMax>> getRepMaxesByLiftType(LiftType liftType) async {
    return RetryUtils.retry(() async {
      try {
        final response = await _supabase
            .from('rep_maxes')
            .select()
            .eq('lift', liftType.value)
            .order('reps');

        return response
            .map<RepMax>((row) => RepMax.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw RepMaxesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<RepMax?> getRepMaxForLiftAndReps(LiftType liftType, int reps) async {
    return RetryUtils.retry(() async {
      try {
        final response = await _supabase
            .from('rep_maxes')
            .select()
            .eq('lift', liftType.value)
            .eq('reps', reps)
            .maybeSingle();

        if (response == null) return null;
        return RepMax.fromSupabaseRow(response);
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw RepMaxesRepositoryException(appError.message);
      }
    });
  }
}

class RepMaxesRepositoryException implements Exception {
  final String message;

  const RepMaxesRepositoryException(this.message);

  @override
  String toString() => 'RepMaxesRepositoryException: $message';
}

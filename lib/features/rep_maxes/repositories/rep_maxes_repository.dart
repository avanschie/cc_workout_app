import 'package:flutter/foundation.dart';
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
        final userId = _supabase.auth.currentUser?.id;
        if (kDebugMode) {
          debugPrint('DEBUG RepMax: Current auth user ID: $userId');
        }

        if (userId == null) {
          throw RepMaxesRepositoryException('User not authenticated');
        }

        if (kDebugMode) {
          debugPrint('DEBUG RepMax: Querying rep_maxes for user: $userId');
        }
        final response = await _supabase
            .from('rep_maxes')
            .select()
            .eq('user_id', userId);

        if (kDebugMode) {
          debugPrint(
            'DEBUG RepMax: Response received: ${response.length} items',
          );
        }
        return response
            .map<RepMax>((row) => RepMax.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('DEBUG RepMax: Error getting rep maxes: $e');
          debugPrint('DEBUG RepMax: Error type: ${e.runtimeType}');
          if (e is PostgrestException) {
            debugPrint('DEBUG RepMax: Postgrest error code: ${e.code}');
            debugPrint('DEBUG RepMax: Postgrest error message: ${e.message}');
            debugPrint('DEBUG RepMax: Postgrest error details: ${e.details}');
            debugPrint('DEBUG RepMax: Postgrest error hint: ${e.hint}');
          }
        }
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw RepMaxesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<List<RepMax>> getRepMaxesByLiftType(LiftType liftType) async {
    return RetryUtils.retry(() async {
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw RepMaxesRepositoryException('User not authenticated');
        }

        final response = await _supabase
            .from('rep_maxes')
            .select()
            .eq('user_id', userId)
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
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw RepMaxesRepositoryException('User not authenticated');
        }

        final response = await _supabase
            .from('rep_maxes')
            .select()
            .eq('user_id', userId)
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

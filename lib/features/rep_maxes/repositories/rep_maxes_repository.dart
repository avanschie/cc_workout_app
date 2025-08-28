import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

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
    try {
      final response = await _supabase.from('rep_maxes').select();

      return response
          .map<RepMax>((row) => RepMax.fromSupabaseRow(row))
          .toList();
    } on PostgrestException catch (e) {
      throw RepMaxesRepositoryException(
        'Failed to fetch rep maxes: ${e.message}',
      );
    } catch (e) {
      throw RepMaxesRepositoryException(
        'An unexpected error occurred while fetching rep maxes',
      );
    }
  }

  @override
  Future<List<RepMax>> getRepMaxesByLiftType(LiftType liftType) async {
    try {
      final response = await _supabase
          .from('rep_maxes')
          .select()
          .eq('lift', liftType.value)
          .order('reps');

      return response
          .map<RepMax>((row) => RepMax.fromSupabaseRow(row))
          .toList();
    } on PostgrestException catch (e) {
      throw RepMaxesRepositoryException(
        'Failed to fetch rep maxes by lift type: ${e.message}',
      );
    } catch (e) {
      throw RepMaxesRepositoryException(
        'An unexpected error occurred while fetching rep maxes by lift type',
      );
    }
  }

  @override
  Future<RepMax?> getRepMaxForLiftAndReps(LiftType liftType, int reps) async {
    try {
      final response = await _supabase
          .from('rep_maxes')
          .select()
          .eq('lift', liftType.value)
          .eq('reps', reps)
          .maybeSingle();

      if (response == null) return null;
      return RepMax.fromSupabaseRow(response);
    } on PostgrestException catch (e) {
      throw RepMaxesRepositoryException(
        'Failed to fetch rep max for lift and reps: ${e.message}',
      );
    } catch (e) {
      throw RepMaxesRepositoryException(
        'An unexpected error occurred while fetching rep max for lift and reps',
      );
    }
  }
}

class RepMaxesRepositoryException implements Exception {
  final String message;

  const RepMaxesRepositoryException(this.message);

  @override
  String toString() => 'RepMaxesRepositoryException: $message';
}

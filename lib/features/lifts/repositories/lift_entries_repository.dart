import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/core/utils/retry_utils.dart';
import 'package:cc_workout_app/core/utils/error_handler.dart';

abstract class LiftEntriesRepository {
  Future<List<LiftEntry>> getAllLiftEntries();
  Future<List<LiftEntry>> getLiftEntriesByType(LiftType liftType);
  Future<LiftEntry> createLiftEntry(LiftEntry liftEntry);
  Future<LiftEntry> updateLiftEntry(LiftEntry liftEntry);
  Future<void> deleteLiftEntry(String id);
}

class SupabaseLiftEntriesRepository implements LiftEntriesRepository {
  final SupabaseClient _supabase;

  SupabaseLiftEntriesRepository(this._supabase);

  @override
  Future<List<LiftEntry>> getAllLiftEntries() async {
    return RetryUtils.retry(() async {
      try {
        final response = await _supabase
            .from('lift_entries')
            .select()
            .order('performed_at', ascending: false)
            .order('created_at', ascending: false);

        return response
            .map<LiftEntry>((row) => LiftEntry.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<List<LiftEntry>> getLiftEntriesByType(LiftType liftType) async {
    return RetryUtils.retry(() async {
      try {
        final response = await _supabase
            .from('lift_entries')
            .select()
            .eq('lift', liftType.value)
            .order('performed_at', ascending: false)
            .order('created_at', ascending: false);

        return response
            .map<LiftEntry>((row) => LiftEntry.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<LiftEntry> createLiftEntry(LiftEntry liftEntry) async {
    if (!liftEntry.isValid) {
      throw LiftEntriesRepositoryException('Invalid lift entry data');
    }

    return RetryUtils.retry(() async {
      try {
        final rowData = liftEntry.toSupabaseRow();

        final response = await _supabase
            .from('lift_entries')
            .insert(rowData)
            .select()
            .single();

        return LiftEntry.fromSupabaseRow(response);
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<LiftEntry> updateLiftEntry(LiftEntry liftEntry) async {
    if (!liftEntry.isValid) {
      throw LiftEntriesRepositoryException('Invalid lift entry data');
    }

    return RetryUtils.retry(() async {
      try {
        final response = await _supabase
            .from('lift_entries')
            .update(liftEntry.toSupabaseRow())
            .eq('id', liftEntry.id)
            .select()
            .single();

        return LiftEntry.fromSupabaseRow(response);
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<void> deleteLiftEntry(String id) async {
    return RetryUtils.retry(() async {
      try {
        await _supabase.from('lift_entries').delete().eq('id', id);
      } catch (e, stackTrace) {
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }
}

class LiftEntriesRepositoryException implements Exception {
  final String message;

  const LiftEntriesRepositoryException(this.message);

  @override
  String toString() => 'LiftEntriesRepositoryException: $message';
}

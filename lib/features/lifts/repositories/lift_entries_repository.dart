import 'package:flutter/foundation.dart';
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
        final userId = _supabase.auth.currentUser?.id;
        if (kDebugMode) {
          debugPrint('DEBUG LiftEntries: Current auth user ID: $userId');
        }

        if (userId == null) {
          throw LiftEntriesRepositoryException('User not authenticated');
        }

        final response = await _supabase
            .from('lift_entries')
            .select()
            .eq('user_id', userId) // CRITICAL: Filter by current user only!
            .order('performed_at', ascending: false)
            .order('created_at', ascending: false);

        if (kDebugMode) {
          debugPrint(
            'DEBUG LiftEntries: Response received: ${response.length} items for user: $userId',
          );
        }
        return response
            .map<LiftEntry>((row) => LiftEntry.fromSupabaseRow(row))
            .toList();
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('DEBUG LiftEntries: Error getting lift entries: $e');
        }
        final appError = ErrorHandler.handleError(e, stackTrace);
        throw LiftEntriesRepositoryException(appError.message);
      }
    });
  }

  @override
  Future<List<LiftEntry>> getLiftEntriesByType(LiftType liftType) async {
    return RetryUtils.retry(() async {
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw LiftEntriesRepositoryException('User not authenticated');
        }

        final response = await _supabase
            .from('lift_entries')
            .select()
            .eq('user_id', userId) // CRITICAL: Filter by current user only!
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
        // Debug: Check current authenticated user
        final currentUserId = _supabase.auth.currentUser?.id;
        if (kDebugMode) {
          debugPrint('DEBUG: Current auth user ID: $currentUserId');
          debugPrint('DEBUG: LiftEntry user ID: ${liftEntry.userId}');
        }

        if (currentUserId == null) {
          throw LiftEntriesRepositoryException('No authenticated user');
        }

        if (currentUserId != liftEntry.userId) {
          if (kDebugMode) {
            debugPrint(
              'WARNING: User ID mismatch! Auth: $currentUserId, Entry: ${liftEntry.userId}',
            );
          }
        }

        final rowData = liftEntry.toSupabaseRow();
        if (kDebugMode) {
          debugPrint('DEBUG: Row data being inserted: $rowData');
        }

        // First, let's try to check if the table exists
        if (kDebugMode) {
          try {
            await _supabase.from('lift_entries').select('id').limit(1);
            debugPrint('DEBUG: Table exists check passed');
          } catch (tableError) {
            debugPrint('DEBUG: Table check error: $tableError');
          }
        }

        final response = await _supabase
            .from('lift_entries')
            .insert(rowData)
            .select()
            .single();

        return LiftEntry.fromSupabaseRow(response);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('DEBUG: Error creating lift entry: $e');
          debugPrint('DEBUG: Error type: ${e.runtimeType}');
          if (e is PostgrestException) {
            debugPrint('DEBUG: Postgrest error code: ${e.code}');
            debugPrint('DEBUG: Postgrest error message: ${e.message}');
            debugPrint('DEBUG: Postgrest error details: ${e.details}');
            debugPrint('DEBUG: Postgrest error hint: ${e.hint}');
          }
        }
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
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw LiftEntriesRepositoryException('User not authenticated');
        }

        // Ensure user owns this entry
        if (liftEntry.userId != userId) {
          throw LiftEntriesRepositoryException(
            'Unauthorized: Cannot update entry owned by another user',
          );
        }

        final response = await _supabase
            .from('lift_entries')
            .update(liftEntry.toSupabaseRow())
            .eq('id', liftEntry.id)
            .eq(
              'user_id',
              userId,
            ) // Extra safety: ensure we only update our own entries
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
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw LiftEntriesRepositoryException('User not authenticated');
        }

        // Only delete entries owned by the current user
        await _supabase
            .from('lift_entries')
            .delete()
            .eq('id', id)
            .eq(
              'user_id',
              userId,
            ); // Extra safety: ensure we only delete our own entries
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

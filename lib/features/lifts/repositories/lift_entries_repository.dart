import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

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
    try {
      final response = await _supabase
          .from('lift_entries')
          .select()
          .order('performed_at', ascending: false)
          .order('created_at', ascending: false);

      return response
          .map<LiftEntry>((row) => LiftEntry.fromSupabaseRow(row))
          .toList();
    } on PostgrestException catch (e) {
      throw LiftEntriesRepositoryException(
        'Failed to fetch lift entries: ${e.message}',
      );
    } catch (e) {
      throw LiftEntriesRepositoryException(
        'An unexpected error occurred while fetching lift entries',
      );
    }
  }

  @override
  Future<List<LiftEntry>> getLiftEntriesByType(LiftType liftType) async {
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
    } on PostgrestException catch (e) {
      throw LiftEntriesRepositoryException(
        'Failed to fetch lift entries by type: ${e.message}',
      );
    } catch (e) {
      throw LiftEntriesRepositoryException(
        'An unexpected error occurred while fetching lift entries by type',
      );
    }
  }

  @override
  Future<LiftEntry> createLiftEntry(LiftEntry liftEntry) async {
    if (!liftEntry.isValid) {
      throw LiftEntriesRepositoryException('Invalid lift entry data');
    }

    try {
      final rowData = liftEntry.toSupabaseRow();

      final response = await _supabase
          .from('lift_entries')
          .insert(rowData)
          .select()
          .single();

      return LiftEntry.fromSupabaseRow(response);
    } on PostgrestException catch (e) {
      throw LiftEntriesRepositoryException(
        'Failed to create lift entry: ${e.message} (Code: ${e.code})',
      );
    } catch (e) {
      throw LiftEntriesRepositoryException(
        'An unexpected error occurred while creating lift entry: $e',
      );
    }
  }

  @override
  Future<LiftEntry> updateLiftEntry(LiftEntry liftEntry) async {
    if (!liftEntry.isValid) {
      throw LiftEntriesRepositoryException('Invalid lift entry data');
    }

    try {
      final response = await _supabase
          .from('lift_entries')
          .update(liftEntry.toSupabaseRow())
          .eq('id', liftEntry.id)
          .select()
          .single();

      return LiftEntry.fromSupabaseRow(response);
    } on PostgrestException catch (e) {
      throw LiftEntriesRepositoryException(
        'Failed to update lift entry: ${e.message}',
      );
    } catch (e) {
      throw LiftEntriesRepositoryException(
        'An unexpected error occurred while updating lift entry',
      );
    }
  }

  @override
  Future<void> deleteLiftEntry(String id) async {
    try {
      await _supabase.from('lift_entries').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw LiftEntriesRepositoryException(
        'Failed to delete lift entry: ${e.message}',
      );
    } catch (e) {
      throw LiftEntriesRepositoryException(
        'An unexpected error occurred while deleting lift entry',
      );
    }
  }
}

class LiftEntriesRepositoryException implements Exception {
  final String message;

  const LiftEntriesRepositoryException(this.message);

  @override
  String toString() => 'LiftEntriesRepositoryException: $message';
}

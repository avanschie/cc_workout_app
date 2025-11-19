import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';

abstract class LiftEntriesRepository {
  Future<List<LiftEntry>> getAllLiftEntries();
  Future<List<LiftEntry>> getLiftEntriesByType(LiftType liftType);
  Future<LiftEntry> createLiftEntry(LiftEntry liftEntry);
  Future<LiftEntry> updateLiftEntry(LiftEntry liftEntry);
  Future<void> deleteLiftEntry(String id);
}

class LiftEntriesRepositoryException implements Exception {
  const LiftEntriesRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'LiftEntriesRepositoryException: $message';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/repositories/lift_entries_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final liftEntriesRepositoryProvider = Provider<LiftEntriesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseLiftEntriesRepository(supabaseClient);
});

final liftEntriesProvider = FutureProvider.autoDispose<List<LiftEntry>>((
  ref,
) async {
  final repository = ref.watch(liftEntriesRepositoryProvider);
  return repository.getAllLiftEntries();
});

final liftEntriesByTypeProvider = FutureProvider.autoDispose
    .family<List<LiftEntry>, LiftType>((ref, liftType) async {
      final repository = ref.watch(liftEntriesRepositoryProvider);
      return repository.getLiftEntriesByType(liftType);
    });

class CreateLiftEntryNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createLiftEntry(LiftEntry liftEntry) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.createLiftEntry(liftEntry);
      ref.invalidate(liftEntriesProvider);
      ref.invalidate(liftEntriesByTypeProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final createLiftEntryProvider =
    AutoDisposeAsyncNotifierProvider<CreateLiftEntryNotifier, void>(() {
      return CreateLiftEntryNotifier();
    });

class UpdateLiftEntryNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateLiftEntry(LiftEntry liftEntry) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.updateLiftEntry(liftEntry);
      ref.invalidate(liftEntriesProvider);
      ref.invalidate(liftEntriesByTypeProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final updateLiftEntryProvider =
    AutoDisposeAsyncNotifierProvider<UpdateLiftEntryNotifier, void>(() {
      return UpdateLiftEntryNotifier();
    });

class DeleteLiftEntryNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteLiftEntry(String id) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.deleteLiftEntry(id);
      ref.invalidate(liftEntriesProvider);
      ref.invalidate(liftEntriesByTypeProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final deleteLiftEntryProvider =
    AutoDisposeAsyncNotifierProvider<DeleteLiftEntryNotifier, void>(() {
      return DeleteLiftEntryNotifier();
    });

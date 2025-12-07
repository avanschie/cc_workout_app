import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/domain/repositories/lift_entries_repository.dart';
import 'package:cc_workout_app/features/lifts/data/repositories/supabase_lift_entries_repository.dart';

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
  // Keep alive for better performance since this is frequently accessed
  final link = ref.keepAlive();

  // Auto-dispose after 5 minutes of inactivity for memory management
  Timer(const Duration(minutes: 5), link.close);

  final repository = ref.watch(liftEntriesRepositoryProvider);
  return repository.getAllLiftEntries();
});

final liftEntriesByTypeProvider = FutureProvider.autoDispose
    .family<List<LiftEntry>, LiftType>((ref, liftType) async {
      final repository = ref.watch(liftEntriesRepositoryProvider);
      return repository.getLiftEntriesByType(liftType);
    });

class CreateLiftEntryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createLiftEntry(LiftEntry liftEntry) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.createLiftEntry(liftEntry);
      // Invalidate lift entries providers - rep maxes will auto-refresh via dependencies
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
    AsyncNotifierProvider<CreateLiftEntryNotifier, void>(() {
      return CreateLiftEntryNotifier();
    });

class UpdateLiftEntryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateLiftEntry(LiftEntry liftEntry) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.updateLiftEntry(liftEntry);
      // Invalidate lift entries providers - rep maxes will auto-refresh via dependencies
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
    AsyncNotifierProvider<UpdateLiftEntryNotifier, void>(() {
      return UpdateLiftEntryNotifier();
    });

class DeleteLiftEntryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteLiftEntry(String id) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(liftEntriesRepositoryProvider);
      await repository.deleteLiftEntry(id);
      // Invalidate lift entries providers - rep maxes will auto-refresh via dependencies
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
    AsyncNotifierProvider<DeleteLiftEntryNotifier, void>(() {
      return DeleteLiftEntryNotifier();
    });

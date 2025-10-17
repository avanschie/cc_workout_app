import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/lifts/providers/lift_entries_providers.dart' hide supabaseClientProvider;
import 'package:cc_workout_app/features/rep_maxes/repositories/rep_maxes_repository.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';

final repMaxesRepositoryProvider = Provider<RepMaxesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseRepMaxesRepository(supabaseClient);
});

final repMaxCalculationServiceProvider = Provider<RepMaxCalculationService>((
  ref,
) {
  final repository = ref.watch(repMaxesRepositoryProvider);
  return RepMaxCalculationService(repository);
});

final allRepMaxesProvider = FutureProvider.autoDispose<List<RepMax>>((ref) async {
  // Keep alive for better performance since this is frequently accessed
  final link = ref.keepAlive();

  // Auto-dispose after 5 minutes of inactivity for memory management
  Timer(const Duration(minutes: 5), link.close);

  // Watch lift entries to automatically refresh when they change
  ref.watch(liftEntriesProvider);
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateAllRepMaxes();
});

final repMaxesByLiftProvider = FutureProvider<Map<LiftType, List<RepMax>>>((
  ref,
) async {
  // Watch lift entries to automatically refresh when they change
  ref.watch(liftEntriesProvider);
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateRepMaxesByLift();
});

final repMaxesForLiftProvider = FutureProvider.family<List<RepMax>, LiftType>((
  ref,
  liftType,
) async {
  // Watch lift entries for this specific lift type to automatically refresh
  ref.watch(liftEntriesByTypeProvider(liftType));
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateRepMaxesForLift(liftType);
});

final repMaxForLiftAndRepsProvider =
    FutureProvider.family<RepMax?, ({LiftType liftType, int reps})>((
      ref,
      params,
    ) async {
      // Watch lift entries for this specific lift type to automatically refresh
      ref.watch(liftEntriesByTypeProvider(params.liftType));
      final service = ref.watch(repMaxCalculationServiceProvider);
      return await service.getRepMaxForLiftAndReps(
        params.liftType,
        params.reps,
      );
    });

final repMaxTableForLiftProvider =
    FutureProvider.family<Map<int, RepMax>, LiftType>((ref, liftType) async {
      // Watch lift entries for this specific lift type to automatically refresh
      ref.watch(liftEntriesByTypeProvider(liftType));
      final service = ref.watch(repMaxCalculationServiceProvider);
      return await service.getRepMaxTableForLift(liftType);
    });

final fullRepMaxTableProvider = FutureProvider.autoDispose<Map<LiftType, Map<int, RepMax>>>(
  (ref) async {
    // Keep alive for better performance since this is frequently accessed
    final link = ref.keepAlive();

    // Auto-dispose after 5 minutes of inactivity for memory management
    Timer(const Duration(minutes: 5), link.close);

    // Watch all lift entries to automatically refresh when they change
    ref.watch(liftEntriesProvider);
    final service = ref.watch(repMaxCalculationServiceProvider);
    return await service.getFullRepMaxTable();
  },
);

class RepMaxNotifier extends AutoDisposeAsyncNotifier<List<RepMax>> {
  @override
  Future<List<RepMax>> build() async {
    // Watch lift entries to automatically refresh when they change
    ref.watch(liftEntriesProvider);
    final service = ref.watch(repMaxCalculationServiceProvider);
    return await service.calculateAllRepMaxes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(repMaxCalculationServiceProvider);
      return await service.calculateAllRepMaxes();
    });
  }
}

final repMaxNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RepMaxNotifier, List<RepMax>>(
      RepMaxNotifier.new,
    );

class RepMaxTableNotifier
    extends AutoDisposeAsyncNotifier<Map<LiftType, Map<int, RepMax>>> {
  @override
  Future<Map<LiftType, Map<int, RepMax>>> build() async {
    // Watch lift entries to automatically refresh when they change
    ref.watch(liftEntriesProvider);
    final service = ref.watch(repMaxCalculationServiceProvider);
    return await service.getFullRepMaxTable();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(repMaxCalculationServiceProvider);
      return await service.getFullRepMaxTable();
    });
  }
}

final repMaxTableNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      RepMaxTableNotifier,
      Map<LiftType, Map<int, RepMax>>
    >(RepMaxTableNotifier.new);

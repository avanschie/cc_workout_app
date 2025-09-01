import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/repositories/rep_maxes_repository.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';

final repMaxesRepositoryProvider = Provider<RepMaxesRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseRepMaxesRepository(supabase);
});

final repMaxCalculationServiceProvider = Provider<RepMaxCalculationService>((
  ref,
) {
  final repository = ref.watch(repMaxesRepositoryProvider);
  return RepMaxCalculationService(repository);
});

final allRepMaxesProvider = FutureProvider<List<RepMax>>((ref) async {
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateAllRepMaxes();
});

final repMaxesByLiftProvider = FutureProvider<Map<LiftType, List<RepMax>>>((
  ref,
) async {
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateRepMaxesByLift();
});

final repMaxesForLiftProvider = FutureProvider.family<List<RepMax>, LiftType>((
  ref,
  liftType,
) async {
  final service = ref.watch(repMaxCalculationServiceProvider);
  return await service.calculateRepMaxesForLift(liftType);
});

final repMaxForLiftAndRepsProvider =
    FutureProvider.family<RepMax?, ({LiftType liftType, int reps})>((
      ref,
      params,
    ) async {
      final service = ref.watch(repMaxCalculationServiceProvider);
      return await service.getRepMaxForLiftAndReps(
        params.liftType,
        params.reps,
      );
    });

final repMaxTableForLiftProvider =
    FutureProvider.family<Map<int, RepMax>, LiftType>((ref, liftType) async {
      final service = ref.watch(repMaxCalculationServiceProvider);
      return await service.getRepMaxTableForLift(liftType);
    });

final fullRepMaxTableProvider = FutureProvider<Map<LiftType, Map<int, RepMax>>>(
  (ref) async {
    final service = ref.watch(repMaxCalculationServiceProvider);
    return await service.getFullRepMaxTable();
  },
);

class RepMaxNotifier extends AutoDisposeAsyncNotifier<List<RepMax>> {
  @override
  Future<List<RepMax>> build() async {
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

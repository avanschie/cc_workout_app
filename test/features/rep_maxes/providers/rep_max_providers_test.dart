import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/repositories/rep_maxes_repository.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';

import 'rep_max_providers_test.mocks.dart';

@GenerateMocks([RepMaxesRepository, RepMaxCalculationService])
void main() {
  late MockRepMaxCalculationService mockService;

  setUp(() {
    mockService = MockRepMaxCalculationService();
  });

  group('RepMax Providers', () {
    final sampleRepMaxes = [
      RepMax(
        userId: 'user1',
        lift: LiftType.squat,
        reps: 1,
        weightKg: 200.0,
        lastPerformedAt: DateTime(2023, 1, 1),
      ),
      RepMax(
        userId: 'user1',
        lift: LiftType.bench,
        reps: 5,
        weightKg: 120.0,
        lastPerformedAt: DateTime(2023, 1, 2),
      ),
    ];

    group('allRepMaxesProvider', () {
      test('should return all rep maxes', () async {
        when(
          mockService.calculateAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(allRepMaxesProvider.future);

        expect(result, equals(sampleRepMaxes));
        verify(mockService.calculateAllRepMaxes()).called(1);
      });

      test('should handle service errors', () async {
        when(
          mockService.calculateAllRepMaxes(),
        ).thenThrow(const RepMaxCalculationServiceException('Test error'));

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        expect(
          () => container.read(allRepMaxesProvider.future),
          throwsA(isA<RepMaxCalculationServiceException>()),
        );
      });
    });

    group('repMaxesByLiftProvider', () {
      test('should return rep maxes grouped by lift type', () async {
        final groupedData = {
          LiftType.squat: [sampleRepMaxes[0]],
          LiftType.bench: [sampleRepMaxes[1]],
          LiftType.deadlift: <RepMax>[],
        };

        when(
          mockService.calculateRepMaxesByLift(),
        ).thenAnswer((_) async => groupedData);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(repMaxesByLiftProvider.future);

        expect(result, equals(groupedData));
        verify(mockService.calculateRepMaxesByLift()).called(1);
      });
    });

    group('repMaxesForLiftProvider', () {
      test('should return rep maxes for specific lift type', () async {
        final squatRepMaxes = [sampleRepMaxes[0]];

        when(
          mockService.calculateRepMaxesForLift(LiftType.squat),
        ).thenAnswer((_) async => squatRepMaxes);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(
          repMaxesForLiftProvider(LiftType.squat).future,
        );

        expect(result, equals(squatRepMaxes));
        verify(mockService.calculateRepMaxesForLift(LiftType.squat)).called(1);
      });
    });

    group('repMaxForLiftAndRepsProvider', () {
      test('should return rep max for specific lift and reps', () async {
        final expectedRepMax = sampleRepMaxes[0];

        when(
          mockService.getRepMaxForLiftAndReps(LiftType.squat, 1),
        ).thenAnswer((_) async => expectedRepMax);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(
          repMaxForLiftAndRepsProvider((
            liftType: LiftType.squat,
            reps: 1,
          )).future,
        );

        expect(result, equals(expectedRepMax));
        verify(
          mockService.getRepMaxForLiftAndReps(LiftType.squat, 1),
        ).called(1);
      });

      test('should return null when no rep max exists', () async {
        when(
          mockService.getRepMaxForLiftAndReps(LiftType.bench, 10),
        ).thenAnswer((_) async => null);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(
          repMaxForLiftAndRepsProvider((
            liftType: LiftType.bench,
            reps: 10,
          )).future,
        );

        expect(result, isNull);
      });
    });

    group('repMaxTableForLiftProvider', () {
      test('should return rep max table for specific lift', () async {
        final table = {1: sampleRepMaxes[0]};

        when(
          mockService.getRepMaxTableForLift(LiftType.squat),
        ).thenAnswer((_) async => table);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(
          repMaxTableForLiftProvider(LiftType.squat).future,
        );

        expect(result, equals(table));
        verify(mockService.getRepMaxTableForLift(LiftType.squat)).called(1);
      });
    });

    group('fullRepMaxTableProvider', () {
      test('should return complete rep max table', () async {
        final fullTable = {
          LiftType.squat: {1: sampleRepMaxes[0]},
          LiftType.bench: {5: sampleRepMaxes[1]},
          LiftType.deadlift: <int, RepMax>{},
        };

        when(
          mockService.getFullRepMaxTable(),
        ).thenAnswer((_) async => fullTable);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(fullRepMaxTableProvider.future);

        expect(result, equals(fullTable));
        verify(mockService.getFullRepMaxTable()).called(1);
      });
    });

    group('RepMaxNotifier', () {
      test('should build with initial rep maxes', () async {
        when(
          mockService.calculateAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(repMaxNotifierProvider.future);

        expect(result, equals(sampleRepMaxes));
      });

      test('should refresh data', () async {
        when(
          mockService.calculateAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final notifier = container.read(repMaxNotifierProvider.notifier);
        await notifier.refresh();

        verify(mockService.calculateAllRepMaxes()).called(2);
      });
    });

    group('RepMaxTableNotifier', () {
      test('should build with initial rep max table', () async {
        final fullTable = {
          LiftType.squat: {1: sampleRepMaxes[0]},
          LiftType.bench: {5: sampleRepMaxes[1]},
          LiftType.deadlift: <int, RepMax>{},
        };

        when(
          mockService.getFullRepMaxTable(),
        ).thenAnswer((_) async => fullTable);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final result = await container.read(repMaxTableNotifierProvider.future);

        expect(result, equals(fullTable));
      });

      test('should refresh table data', () async {
        final fullTable = {
          LiftType.squat: {1: sampleRepMaxes[0]},
          LiftType.bench: {5: sampleRepMaxes[1]},
          LiftType.deadlift: <int, RepMax>{},
        };

        when(
          mockService.getFullRepMaxTable(),
        ).thenAnswer((_) async => fullTable);

        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );

        final notifier = container.read(repMaxTableNotifierProvider.notifier);
        await notifier.refresh();

        verify(mockService.getFullRepMaxTable()).called(2);
      });
    });
  });
}

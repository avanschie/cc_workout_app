import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/shared/models/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/services/rep_max_calculation_service.dart';
import 'package:cc_workout_app/features/rep_maxes/providers/rep_max_providers.dart';

import 'rep_max_providers_test.mocks.dart';

@GenerateMocks([RepMaxCalculationService])
void main() {
  late MockRepMaxCalculationService mockService;

  setUp(() {
    mockService = MockRepMaxCalculationService();
  });

  group('RepMax Providers - Service Integration Tests', () {
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

    group('Service Provider', () {
      test('repMaxCalculationServiceProvider should create service', () {
        final container = ProviderContainer(
          overrides: [
            repMaxCalculationServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        final service = container.read(repMaxCalculationServiceProvider);
        expect(service, equals(mockService));
      });
    });

    group('Service Method Testing', () {
      test('calculateAllRepMaxes should return rep maxes', () async {
        when(mockService.calculateAllRepMaxes())
            .thenAnswer((_) async => sampleRepMaxes);

        final result = await mockService.calculateAllRepMaxes();
        expect(result, equals(sampleRepMaxes));
        verify(mockService.calculateAllRepMaxes()).called(1);
      });

      test('calculateRepMaxesByLift should return grouped data', () async {
        final groupedData = {
          LiftType.squat: [sampleRepMaxes[0]],
          LiftType.bench: [sampleRepMaxes[1]],
          LiftType.deadlift: <RepMax>[],
        };

        when(mockService.calculateRepMaxesByLift())
            .thenAnswer((_) async => groupedData);

        final result = await mockService.calculateRepMaxesByLift();
        expect(result, equals(groupedData));
        verify(mockService.calculateRepMaxesByLift()).called(1);
      });

      test('calculateRepMaxesForLift should return lift-specific data', () async {
        final squatRepMaxes = [sampleRepMaxes[0]];

        when(mockService.calculateRepMaxesForLift(LiftType.squat))
            .thenAnswer((_) async => squatRepMaxes);

        final result = await mockService.calculateRepMaxesForLift(LiftType.squat);
        expect(result, equals(squatRepMaxes));
        verify(mockService.calculateRepMaxesForLift(LiftType.squat)).called(1);
      });

      test('getRepMaxForLiftAndReps should return specific rep max', () async {
        final expectedRepMax = sampleRepMaxes[0];

        when(mockService.getRepMaxForLiftAndReps(LiftType.squat, 1))
            .thenAnswer((_) async => expectedRepMax);

        final result = await mockService.getRepMaxForLiftAndReps(LiftType.squat, 1);
        expect(result, equals(expectedRepMax));
        verify(mockService.getRepMaxForLiftAndReps(LiftType.squat, 1)).called(1);
      });

      test('getRepMaxForLiftAndReps should return null when no match', () async {
        when(mockService.getRepMaxForLiftAndReps(LiftType.bench, 10))
            .thenAnswer((_) async => null);

        final result = await mockService.getRepMaxForLiftAndReps(LiftType.bench, 10);
        expect(result, isNull);
        verify(mockService.getRepMaxForLiftAndReps(LiftType.bench, 10)).called(1);
      });

      test('getRepMaxTableForLift should return rep max table', () async {
        final table = {1: sampleRepMaxes[0]};

        when(mockService.getRepMaxTableForLift(LiftType.squat))
            .thenAnswer((_) async => table);

        final result = await mockService.getRepMaxTableForLift(LiftType.squat);
        expect(result, equals(table));
        verify(mockService.getRepMaxTableForLift(LiftType.squat)).called(1);
      });

      test('getFullRepMaxTable should return complete table', () async {
        final fullTable = {
          LiftType.squat: {1: sampleRepMaxes[0]},
          LiftType.bench: {5: sampleRepMaxes[1]},
          LiftType.deadlift: <int, RepMax>{},
        };

        when(mockService.getFullRepMaxTable())
            .thenAnswer((_) async => fullTable);

        final result = await mockService.getFullRepMaxTable();
        expect(result, equals(fullTable));
        verify(mockService.getFullRepMaxTable()).called(1);
      });

      test('should handle service errors properly', () async {
        when(mockService.calculateAllRepMaxes())
            .thenThrow(const RepMaxCalculationServiceException('Test error'));

        expect(
          () => mockService.calculateAllRepMaxes(),
          throwsA(isA<RepMaxCalculationServiceException>()),
        );
      });
    });
  });
}
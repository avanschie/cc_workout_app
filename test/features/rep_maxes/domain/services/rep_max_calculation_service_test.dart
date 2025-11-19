import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/rep_maxes/domain/entities/rep_max.dart';
import 'package:cc_workout_app/features/rep_maxes/domain/repositories/rep_maxes_repository.dart';
import 'package:cc_workout_app/features/rep_maxes/domain/services/rep_max_calculation_service.dart';

import 'rep_max_calculation_service_test.mocks.dart';

@GenerateMocks([RepMaxesRepository])
void main() {
  late MockRepMaxesRepository mockRepository;
  late RepMaxCalculationService service;

  setUp(() {
    mockRepository = MockRepMaxesRepository();
    service = RepMaxCalculationService(mockRepository);
  });

  group('RepMaxCalculationService', () {
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
        lift: LiftType.squat,
        reps: 5,
        weightKg: 180.0,
        lastPerformedAt: DateTime(2023, 1, 2),
      ),
      RepMax(
        userId: 'user1',
        lift: LiftType.bench,
        reps: 1,
        weightKg: 150.0,
        lastPerformedAt: DateTime(2023, 1, 3),
      ),
      RepMax(
        userId: 'user1',
        lift: LiftType.deadlift,
        reps: 3,
        weightKg: 220.0,
        lastPerformedAt: DateTime(2023, 1, 4),
      ),
    ];

    group('calculateAllRepMaxes', () {
      test('should return all rep maxes from repository', () async {
        when(
          mockRepository.getAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final result = await service.calculateAllRepMaxes();

        expect(result, equals(sampleRepMaxes));
        verify(mockRepository.getAllRepMaxes()).called(1);
      });
    });

    group('calculateRepMaxesByLift', () {
      test('should group rep maxes by lift type and sort by reps', () async {
        when(
          mockRepository.getAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final result = await service.calculateRepMaxesByLift();

        expect(result.keys, containsAll(LiftType.values));
        expect(result[LiftType.squat]?.length, equals(2));
        expect(result[LiftType.bench]?.length, equals(1));
        expect(result[LiftType.deadlift]?.length, equals(1));

        expect(result[LiftType.squat]?[0].reps, equals(1));
        expect(result[LiftType.squat]?[1].reps, equals(5));
      });

      test('should handle empty rep maxes', () async {
        when(mockRepository.getAllRepMaxes()).thenAnswer((_) async => []);

        final result = await service.calculateRepMaxesByLift();

        expect(result.keys, containsAll(LiftType.values));
        for (final liftType in LiftType.values) {
          expect(result[liftType], isEmpty);
        }
      });
    });

    group('calculateRepMaxesForLift', () {
      test('should return rep maxes for specific lift type', () async {
        final squatRepMaxes = sampleRepMaxes
            .where((rm) => rm.lift == LiftType.squat)
            .toList();

        when(
          mockRepository.getRepMaxesByLiftType(LiftType.squat),
        ).thenAnswer((_) async => squatRepMaxes);

        final result = await service.calculateRepMaxesForLift(LiftType.squat);

        expect(result, equals(squatRepMaxes));
        verify(mockRepository.getRepMaxesByLiftType(LiftType.squat)).called(1);
      });
    });

    group('getRepMaxForLiftAndReps', () {
      test('should return rep max for specific lift and reps', () async {
        final expectedRepMax = sampleRepMaxes[0];

        when(
          mockRepository.getRepMaxForLiftAndReps(LiftType.squat, 1),
        ).thenAnswer((_) async => expectedRepMax);

        final result = await service.getRepMaxForLiftAndReps(LiftType.squat, 1);

        expect(result, equals(expectedRepMax));
        verify(
          mockRepository.getRepMaxForLiftAndReps(LiftType.squat, 1),
        ).called(1);
      });

      test('should return null when no rep max exists', () async {
        when(
          mockRepository.getRepMaxForLiftAndReps(LiftType.bench, 10),
        ).thenAnswer((_) async => null);

        final result = await service.getRepMaxForLiftAndReps(
          LiftType.bench,
          10,
        );

        expect(result, isNull);
      });

      test('should throw ArgumentError for invalid reps', () async {
        expect(
          () => service.getRepMaxForLiftAndReps(LiftType.squat, 0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => service.getRepMaxForLiftAndReps(LiftType.squat, 11),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('getRepMaxTableForLift', () {
      test('should return map of reps to rep max for specific lift', () async {
        final squatRepMaxes = [
          RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 1,
            weightKg: 200.0,
            lastPerformedAt: DateTime(2023, 1, 1),
          ),
          RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 5,
            weightKg: 180.0,
            lastPerformedAt: DateTime(2023, 1, 2),
          ),
        ];

        when(
          mockRepository.getRepMaxesByLiftType(LiftType.squat),
        ).thenAnswer((_) async => squatRepMaxes);

        final result = await service.getRepMaxTableForLift(LiftType.squat);

        expect(result.keys, containsAll([1, 5]));
        expect(result[1]?.weightKg, equals(200.0));
        expect(result[5]?.weightKg, equals(180.0));
      });

      test('should filter out invalid rep ranges', () async {
        final invalidRepMaxes = [
          RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 0,
            weightKg: 200.0,
            lastPerformedAt: DateTime(2023, 1, 1),
          ),
          RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 11,
            weightKg: 180.0,
            lastPerformedAt: DateTime(2023, 1, 2),
          ),
          RepMax(
            userId: 'user1',
            lift: LiftType.squat,
            reps: 5,
            weightKg: 170.0,
            lastPerformedAt: DateTime(2023, 1, 3),
          ),
        ];

        when(
          mockRepository.getRepMaxesByLiftType(LiftType.squat),
        ).thenAnswer((_) async => invalidRepMaxes);

        final result = await service.getRepMaxTableForLift(LiftType.squat);

        expect(result.keys, equals([5]));
        expect(result[5]?.weightKg, equals(170.0));
      });
    });

    group('getFullRepMaxTable', () {
      test('should return complete rep max table for all lifts', () async {
        when(
          mockRepository.getAllRepMaxes(),
        ).thenAnswer((_) async => sampleRepMaxes);

        final result = await service.getFullRepMaxTable();

        expect(result.keys, containsAll(LiftType.values));
        expect(result[LiftType.squat]?.keys, containsAll([1, 5]));
        expect(result[LiftType.bench]?.keys, contains(1));
        expect(result[LiftType.deadlift]?.keys, contains(3));
      });

      test('should handle empty data gracefully', () async {
        when(mockRepository.getAllRepMaxes()).thenAnswer((_) async => []);

        final result = await service.getFullRepMaxTable();

        expect(result.keys, containsAll(LiftType.values));
        for (final liftType in LiftType.values) {
          expect(result[liftType], isEmpty);
        }
      });
    });
  });
}

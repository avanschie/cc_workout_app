import 'package:flutter/material.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/rep_maxes/domain/entities/rep_max.dart';
import 'package:cc_workout_app/shared/constants/lift_colors.dart';

class RepMaxTableWidget extends StatelessWidget {
  const RepMaxTableWidget({super.key, required this.repMaxTable});

  final Map<LiftType, Map<int, RepMax>> repMaxTable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              final reps = index + 1;
              return _buildRepMaxRow(context, reps, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Reps',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
              ),
            ),
          ),
          ...LiftType.values.map(
            (liftType) => Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: LiftColors.getColor(liftType),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getShortLiftName(liftType),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepMaxRow(BuildContext context, int reps, int index) {
    final hasAnyDataInRow = LiftType.values.any(
      (liftType) => repMaxTable[liftType]?[reps] != null,
    );

    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: index % 2 == 1
            ? Theme.of(context).colorScheme.surfaceContainerLowest
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: hasAnyDataInRow
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$reps',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasAnyDataInRow
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          ...LiftType.values.map((liftType) {
            final repMax = repMaxTable[liftType]?[reps];
            final hasData = repMax != null;
            final liftColor = LiftColors.getColor(liftType);

            return Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: hasData ? liftColor.withValues(alpha: 0.08) : null,
                  borderRadius: BorderRadius.circular(6),
                  border: hasData
                      ? Border.all(
                          color: liftColor.withValues(alpha: 0.25),
                        )
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    hasData ? '${_formatWeight(repMax.weightKg)} kg' : '—',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: hasData ? FontWeight.w700 : FontWeight.w400,
                      color: hasData
                          ? liftColor.withValues(alpha: 0.9)
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatWeight(double weight) {
    String formatted = weight.toStringAsFixed(2);

    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }

  String _getShortLiftName(LiftType liftType) {
    switch (liftType) {
      case LiftType.squat:
        return 'Squat';
      case LiftType.bench:
        return 'Bench';
      case LiftType.deadlift:
        return 'Deadlift';
    }
  }
}

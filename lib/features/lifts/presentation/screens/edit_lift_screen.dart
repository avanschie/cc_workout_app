import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cc_workout_app/features/lifts/domain/entities/lift_entry.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/lifts/application/providers/history_providers.dart';
import 'package:cc_workout_app/features/lifts/application/providers/lift_entries_providers.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';
import 'package:cc_workout_app/features/lifts/application/forms/lift_form_state.dart';

class EditLiftScreen extends ConsumerStatefulWidget {
  const EditLiftScreen({super.key, required this.liftEntry});

  final LiftEntry liftEntry;

  @override
  ConsumerState<EditLiftScreen> createState() => _EditLiftScreenState();
}

class _EditLiftScreenState extends ConsumerState<EditLiftScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize the form with the lift entry data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(historyControllerProvider);
      controller.startEdit(widget.liftEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(editLiftFormProvider);
    final formNotifier = ref.read(editLiftFormProvider.notifier);
    final updateLiftState = ref.watch(updateLiftEntryProvider);
    final deleteLiftState = ref.watch(deleteLiftEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lift'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: formState.showDeleteConfirmation
                ? null
                : _showDeleteConfirmationDialog,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Lift',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLiftTypeDropdown(formState, formNotifier),
              const SizedBox(height: 16),
              _buildRepsField(formState, formNotifier),
              const SizedBox(height: 16),
              _buildWeightField(formState, formNotifier),
              const SizedBox(height: 16),
              _buildDateField(formState, formNotifier),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          updateLiftState.isLoading || deleteLiftState.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildSaveButton(formState, updateLiftState),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiftTypeDropdown(
    LiftFormState formState,
    EditLiftFormNotifier formNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lift Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<LiftType>(
          key: ValueKey(formState.liftType),
          initialValue: formState.liftType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Select lift type',
            errorText: formState.liftTypeError,
            helperText: 'Choose the exercise you performed',
            prefixIcon: const Icon(Icons.fitness_center),
            errorMaxLines: 2,
          ),
          items: LiftType.values.map((liftType) {
            return DropdownMenuItem(
              value: liftType,
              child: Text(liftType.displayName),
            );
          }).toList(),
          onChanged: (value) => formNotifier.setLiftType(value),
        ),
      ],
    );
  }

  Widget _buildRepsField(
    LiftFormState formState,
    EditLiftFormNotifier formNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reps',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.reps?.toString() ?? '',
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter reps (1-10)',
            errorText: formState.repsError,
            helperText: 'Number of repetitions performed',
            prefixIcon: const Icon(Icons.repeat),
            errorMaxLines: 2,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            formNotifier.setReps(value);
          },
          validator: (value) {
            if (formState.repsError != null) {
              return formState.repsError;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWeightField(
    LiftFormState formState,
    EditLiftFormNotifier formNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight (kg)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.weightKg?.toString() ?? '',
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter weight in kg',
            errorText: formState.weightError,
            suffixText: 'kg',
            helperText: 'Weight lifted in kilograms',
            prefixIcon: const Icon(Icons.fitness_center),
            errorMaxLines: 2,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            formNotifier.setWeight(value);
          },
          validator: (value) {
            if (formState.weightError != null) {
              return formState.weightError;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    LiftFormState formState,
    EditLiftFormNotifier formNotifier,
  ) {
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Performed',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(formNotifier),
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Select date',
              errorText: formState.dateError,
              suffixIcon: const Icon(Icons.calendar_today),
              helperText: 'Date when the lift was performed',
              prefixIcon: const Icon(Icons.event),
              errorMaxLines: 2,
            ),
            child: Text(
              formState.performedAt != null
                  ? dateFormatter.format(formState.performedAt!)
                  : 'Select date',
              style: TextStyle(
                color: formState.performedAt != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    LiftFormState formState,
    AsyncValue<void> updateLiftState,
  ) {
    final isLoading = updateLiftState.isLoading;

    return ElevatedButton(
      onPressed: isLoading || !formState.isValid ? null : _handleSave,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save Changes', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _selectDate(EditLiftFormNotifier formNotifier) async {
    final currentFormState = ref.read(editLiftFormProvider);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentFormState.performedAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      formNotifier.setPerformedAt(selectedDate);
    }
  }

  Future<void> _handleSave() async {
    final formNotifier = ref.read(editLiftFormProvider.notifier);
    final controller = ref.read(historyControllerProvider);

    // Validate Flutter form
    if (!_formKey.currentState!.validate()) {
      SnackBarUtils.showWarning(context, 'Please fix the errors in the form');
      return;
    }

    // Validate all fields first
    formNotifier.validateAll();

    // Check if form is still valid after validation
    final validatedFormState = ref.read(editLiftFormProvider);
    if (!validatedFormState.isValid) {
      SnackBarUtils.showWarning(context, 'Please complete all required fields');
      return;
    }

    try {
      await controller.saveEdit();

      // Show success message and navigate back
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Lift updated successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Update lift error: $e');
        debugPrint('Stack trace: $stackTrace');

        SnackBarUtils.showError(
          context,
          'Failed to update lift: ${e.toString()}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _handleSave,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    final controller = ref.read(historyControllerProvider);
    final entry = widget.liftEntry;
    final dateFormatter = DateFormat('MMM d, yyyy');

    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final deleteLiftState = ref.watch(deleteLiftEntryProvider);
            final isDeleting = deleteLiftState.isLoading;

            return AlertDialog(
              title: const Text('Delete Lift'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Are you sure you want to delete this lift?'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.lift.displayName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('${entry.reps} reps × ${entry.weightKg} kg'),
                        Text(dateFormatter.format(entry.performedAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This action cannot be undone.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () => _handleDelete(dialogContext, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext dialogContext,
    HistoryController controller,
  ) async {
    try {
      await controller.deleteEntry(widget.liftEntry);

      // Close dialog and show success message
      if (mounted && dialogContext.mounted) {
        Navigator.of(dialogContext).pop(true);
      }
      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Lift deleted successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      // Close dialog and show error message
      if (mounted && dialogContext.mounted) {
        Navigator.of(dialogContext).pop(false);
      }
      if (mounted) {
        debugPrint('Delete lift error: $e');
        debugPrint('Stack trace: $stackTrace');

        SnackBarUtils.showError(
          context,
          'Failed to delete lift: ${e.toString()}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _showDeleteConfirmationDialog,
          ),
        );
      }
    }
  }
}

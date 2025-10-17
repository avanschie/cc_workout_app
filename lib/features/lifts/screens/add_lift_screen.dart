import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cc_workout_app/shared/models/lift_type.dart';
import 'package:cc_workout_app/features/auth/application/providers/auth_providers.dart';
import 'package:cc_workout_app/features/lifts/providers/add_lift_form_providers.dart';
import 'package:cc_workout_app/features/lifts/providers/lift_entries_providers.dart';
import 'package:cc_workout_app/core/utils/snackbar_utils.dart';
import 'package:cc_workout_app/shared/forms/lift_form_state.dart';

class AddLiftScreen extends ConsumerStatefulWidget {
  const AddLiftScreen({super.key});

  @override
  ConsumerState<AddLiftScreen> createState() => _AddLiftScreenState();
}

class _AddLiftScreenState extends ConsumerState<AddLiftScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(addLiftFormProvider);
    final formNotifier = ref.read(addLiftFormProvider.notifier);
    final createLiftState = ref.watch(createLiftEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lift'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              _buildSaveButton(formState, createLiftState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiftTypeDropdown(
    LiftFormState formState,
    AddLiftFormNotifier formNotifier,
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
    AddLiftFormNotifier formNotifier,
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
    AddLiftFormNotifier formNotifier,
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
    AddLiftFormNotifier formNotifier,
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
    AsyncValue<void> createLiftState,
  ) {
    final isLoading = createLiftState.isLoading;

    return ElevatedButton(
      onPressed: isLoading || !formState.isValid ? null : _handleSave,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save Lift', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _selectDate(AddLiftFormNotifier formNotifier) async {
    final currentFormState = ref.read(addLiftFormProvider);
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
    final formNotifier = ref.read(addLiftFormProvider.notifier);
    final createLiftNotifier = ref.read(createLiftEntryProvider.notifier);

    // Validate Flutter form
    if (!_formKey.currentState!.validate()) {
      SnackBarUtils.showWarning(context, 'Please fix the errors in the form');
      return;
    }

    // Validate all fields first
    formNotifier.validateAll();

    // Check if form is still valid after validation
    final validatedFormState = ref.read(addLiftFormProvider);
    if (!validatedFormState.isValid) {
      SnackBarUtils.showWarning(context, 'Please complete all required fields');
      return;
    }

    try {
      // Get the current authenticated user
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;

      if (currentUser == null) {
        if (mounted) {
          SnackBarUtils.showError(
            context,
            'You must be signed in to add lifts',
          );
        }
        return;
      }

      final liftEntry = formNotifier.toLiftEntry(currentUser.id);

      if (liftEntry != null) {
        await createLiftNotifier.createLiftEntry(liftEntry);

        // Show success message
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Lift saved successfully!');

          // Clear form and navigate back with success result
          formNotifier.clearForm();
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Save lift error: $e');
        debugPrint('Stack trace: $stackTrace');

        SnackBarUtils.showError(
          context,
          'Failed to save lift: ${e.toString()}',
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _handleSave,
          ),
        );
      }
    }
  }
}

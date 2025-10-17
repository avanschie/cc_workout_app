import 'package:flutter/material.dart';
import 'package:cc_workout_app/core/utils/dialog_utils.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.onConfirmedDelete,
    required this.itemName,
    this.customMessage,
    this.icon,
    this.tooltip,
    this.isIconButton = true,
  });

  final VoidCallback onConfirmedDelete;
  final String itemName;
  final String? customMessage;
  final IconData? icon;
  final String? tooltip;
  final bool isIconButton;

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      return IconButton(
        icon: Icon(icon ?? Icons.delete_outline),
        tooltip: tooltip ?? 'Delete $itemName',
        onPressed: () => _handleDelete(context),
      );
    }

    return TextButton.icon(
      icon: Icon(icon ?? Icons.delete_outline),
      label: const Text('Delete'),
      onPressed: () => _handleDelete(context),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await DialogUtils.showDeleteConfirmationDialog(
      context: context,
      itemName: itemName,
      customMessage: customMessage,
    );

    if (confirmed) {
      onConfirmedDelete();
    }
  }
}

import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration? duration,
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: textColor)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, type: SnackBarType.success);
  }

  static void showError(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 6),
      action: action,
    );
  }

  static void showWarning(BuildContext context, String message) {
    showSnackBar(context, message, type: SnackBarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    showSnackBar(context, message);
  }
}

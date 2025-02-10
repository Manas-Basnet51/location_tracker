import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSettings;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        if (onSettings != null)
          TextButton(
            onPressed: onSettings,
            child: Text(
              'Open Settings',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

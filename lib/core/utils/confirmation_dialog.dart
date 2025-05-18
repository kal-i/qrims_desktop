import 'package:flutter/material.dart';

Future<void> confirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirmed,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'No',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Yes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    onConfirmed();
  }
}

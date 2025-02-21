import 'package:flutter/material.dart';

// Helper function to show the confirmation dialog
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String confirmationTitle,
  required String confirmationMessage,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(confirmationTitle),
        content: Text(confirmationMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User chose "Cancel"
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User chose "Confirm"
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );

  // If the dialog is dismissed, return false (user did not confirm)
  return result ?? false;
}

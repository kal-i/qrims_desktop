import 'package:flutter/material.dart';

Future<void> showDialogUtils({
  required BuildContext context,
  required String headerTitle,
  required Widget content,
  VoidCallback? onCreate,
}) async {
  return showDialog(
    context: context,
    builder: (context) => content,
  );
}

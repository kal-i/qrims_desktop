import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar({
    required BuildContext context,
    IconData? icon,
    required String message,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? Icons.info,
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              message,
            ),
          ],
        ),
      ),
    );
  }
}
